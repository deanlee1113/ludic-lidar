-- 루딕 라이다 사전예약 — Supabase 스키마
-- 원칙: 방문자(anon)는 테이블을 직접 읽거나 쓸 수 없고, 아래 함수 두 개(신청, 이벤트 기록)만 호출할 수 있다.
--       신청 데이터 조회·삭제와 통계는 admins 테이블에 등록된 로그인 사용자만 가능하다.

-- 1) 관리자 목록
create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.admins enable row level security;

create or replace function public.is_admin()
returns boolean
language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.admins where user_id = auth.uid()) $$;

-- 2) 사전예약 신청
create table if not exists public.reservations (
  id          bigint generated always as identity primary key,
  created_at  timestamptz not null default now(),
  name        text not null check (char_length(name) between 1 and 40),
  phone       text not null unique check (phone ~ '^01[016789][0-9]{7,8}$'),
  qty_s65l    int  not null default 0 check (qty_s65l  between 0 and 3),
  qty_c67m    int  not null default 0 check (qty_c67m  between 0 and 3),
  qty_c68mh   int  not null default 0 check (qty_c68mh between 0 and 3),
  agree_privacy boolean not null check (agree_privacy),
  agree_notify  boolean not null check (agree_notify),
  visitor_id  text,
  source      text,
  referrer    text,
  device      text,
  constraint total_1_to_3 check (qty_s65l + qty_c67m + qty_c68mh between 1 and 3)
);
alter table public.reservations enable row level security;

drop policy if exists "admins read reservations" on public.reservations;
create policy "admins read reservations" on public.reservations
  for select to authenticated using (public.is_admin());
drop policy if exists "admins delete reservations" on public.reservations;
create policy "admins delete reservations" on public.reservations
  for delete to authenticated using (public.is_admin());

-- 3) 방문·행동 이벤트 (view, cta, form_start, submit)
create table if not exists public.events (
  id          bigint generated always as identity primary key,
  created_at  timestamptz not null default now(),
  visitor_id  text not null,
  event       text not null check (event in ('view','cta','form_start','submit')),
  path        text,
  source      text,
  referrer    text,
  device      text
);
create index if not exists events_created_idx on public.events (created_at);
create index if not exists events_visitor_idx on public.events (visitor_id);
alter table public.events enable row level security;

drop policy if exists "admins read events" on public.events;
create policy "admins read events" on public.events
  for select to authenticated using (public.is_admin());

-- 4) 신청 함수: 1인(휴대폰 번호) 1건, 모델 상관없이 합계 1~3개
create or replace function public.submit_reservation(
  p_name text, p_phone text,
  p_s65l int, p_c67m int, p_c68mh int,
  p_agree_privacy boolean, p_agree_notify boolean,
  p_visitor text default null, p_source text default null,
  p_referrer text default null, p_device text default null
) returns json
language plpgsql security definer set search_path = public
as $$
declare
  d text := regexp_replace(coalesce(p_phone, ''), '\D', '', 'g');
  n text := btrim(coalesce(p_name, ''));
  s int := coalesce(p_s65l, 0); c int := coalesce(p_c67m, 0); h int := coalesce(p_c68mh, 0);
begin
  -- 2026-11-01 사전예약 마감: 새 신청은 받지 않는다. 다시 열 때는 이 줄과 index.html의 CLOSED를 함께 고친다
  return json_build_object('ok', false, 'code', 'closed');
  if not (coalesce(p_agree_privacy, false) and coalesce(p_agree_notify, false)) then
    return json_build_object('ok', false, 'code', 'agree');
  end if;
  if n = '' or char_length(n) > 40 then
    return json_build_object('ok', false, 'code', 'name');
  end if;
  if d !~ '^01[016789][0-9]{7,8}$' then
    return json_build_object('ok', false, 'code', 'phone');
  end if;
  if s < 0 or c < 0 or h < 0 or s + c + h < 1 or s + c + h > 3 then
    return json_build_object('ok', false, 'code', 'qty');
  end if;
  -- 품절 모델(S-65L, C-67M)은 신청을 받지 않는다. 다시 열 때는 index.html의 SOLD_OUT도 함께 고친다
  if s > 0 or c > 0 then
    return json_build_object('ok', false, 'code', 'soldout');
  end if;
  insert into reservations (name, phone, qty_s65l, qty_c67m, qty_c68mh,
                            agree_privacy, agree_notify, visitor_id, source, referrer, device)
  values (n, d, s, c, h, true, true,
          left(p_visitor, 64), left(p_source, 120), left(p_referrer, 300), left(p_device, 20));
  return json_build_object('ok', true);
exception
  when unique_violation then return json_build_object('ok', false, 'code', 'duplicate');
  when check_violation  then return json_build_object('ok', false, 'code', 'invalid');
end $$;

-- 5) 이벤트 기록 함수
create or replace function public.track_event(
  p_visitor text, p_event text,
  p_path text default null, p_source text default null,
  p_referrer text default null, p_device text default null
) returns void
language plpgsql security definer set search_path = public
as $$
begin
  if p_visitor is null or p_event not in ('view','cta','form_start','submit') then return; end if;
  insert into events (visitor_id, event, path, source, referrer, device)
  values (left(p_visitor, 64), p_event, left(p_path, 200), left(p_source, 120), left(p_referrer, 300), left(p_device, 20));
end $$;

-- 6) 관리자 통계 함수 (KST 기준 일별)
create or replace function public.admin_stats()
returns json
language plpgsql stable security definer set search_path = public
as $$
declare result json;
begin
  if not public.is_admin() then raise exception 'not_admin'; end if;
  select json_build_object(
    'views',          (select count(*) from events where event = 'view'),
    'visitors',       (select count(distinct visitor_id) from events where event = 'view'),
    'cta_visitors',   (select count(distinct visitor_id) from events where event = 'cta'),
    'start_visitors', (select count(distinct visitor_id) from events where event = 'form_start'),
    'reservations',   (select count(*) from reservations),
    'units',          (select coalesce(sum(qty_s65l + qty_c67m + qty_c68mh), 0) from reservations),
    'models', json_build_object(
        'S-65L',  (select coalesce(sum(qty_s65l), 0)  from reservations),
        'C-67M',  (select coalesce(sum(qty_c67m), 0)  from reservations),
        'C-68MH', (select coalesce(sum(qty_c68mh), 0) from reservations)),
    'daily', coalesce((
      select json_agg(x order by x.day) from (
        select d.day,
               (select count(*) from events e where e.event = 'view' and (e.created_at at time zone 'Asia/Seoul')::date = d.day) as views,
               (select count(distinct e.visitor_id) from events e where e.event = 'view' and (e.created_at at time zone 'Asia/Seoul')::date = d.day) as visitors,
               (select count(*) from reservations r where (r.created_at at time zone 'Asia/Seoul')::date = d.day) as reservations
        from (
          select distinct (created_at at time zone 'Asia/Seoul')::date as day from events
          union
          select distinct (created_at at time zone 'Asia/Seoul')::date from reservations
        ) d
      ) x), '[]'::json),
    'sources', coalesce((
      select json_agg(x) from (
        select coalesce(nullif(source, ''), '직접 접속') as name, count(distinct visitor_id) as visitors
        from events where event = 'view'
        group by 1 order by 2 desc limit 10
      ) x), '[]'::json),
    'devices', coalesce((
      select json_agg(x) from (
        select coalesce(device, '알 수 없음') as name, count(distinct visitor_id) as visitors
        from events where event = 'view'
        group by 1 order by 2 desc
      ) x), '[]'::json)
  ) into result;
  return result;
end $$;

-- 7) 권한: 방문자는 함수 두 개만, 관리자 통계는 로그인 사용자(함수 안에서 관리자 확인)
revoke all on public.reservations, public.events, public.admins from anon;
revoke execute on function public.submit_reservation(text,text,int,int,int,boolean,boolean,text,text,text,text) from public;
revoke execute on function public.track_event(text,text,text,text,text,text) from public;
revoke execute on function public.admin_stats() from public;
grant execute on function public.submit_reservation(text,text,int,int,int,boolean,boolean,text,text,text,text) to anon, authenticated;
grant execute on function public.track_event(text,text,text,text,text,text) to anon, authenticated;
revoke execute on function public.admin_stats() from anon;
revoke execute on function public.is_admin() from anon;
grant execute on function public.admin_stats() to authenticated;
grant select, delete on public.reservations to authenticated;
grant select on public.events to authenticated;
