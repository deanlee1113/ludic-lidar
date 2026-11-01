-- 낚맛 창고 털이 라이브 — 판매 목록(stock/)과 구매 접수
-- 원칙: 방문자(anon)는 테이블을 직접 읽거나 쓸 수 없고, 함수 두 개(목록 보기, 구매 접수)만 호출한다.
--       구매자 정보 조회와 접수 상태 변경은 admins 테이블에 등록된 로그인 사용자만 가능하다.
-- 남은 수량 = 판매 시작 재고(qty) − 접수 대기·확정된 주문 수량. 취소하면 그만큼 다시 늘어난다.

-- 1) 판매 품목
create table if not exists public.stock_items (
  id    int primary key,
  kind  text not null check (kind in ('reel','rod')),
  brand text not null,
  name  text not null,
  price int  not null check (price >= 0),
  qty   int  not null check (qty >= 0),
  sort  int  not null
);
alter table public.stock_items enable row level security;
-- 연식·주 용도: 제조사·판매처 자료로 확인한 것만 넣는다(모르면 비워 둠)
alter table public.stock_items add column if not exists model_year text;
alter table public.stock_items add column if not exists fishing text;
-- 추천 품목(루딕 라이다): 배지 문구, 줄 그어 보여 줄 기존 판매가, 한 번에 접수할 수 있는 최대 수량(없으면 10)
alter table public.stock_items add column if not exists badge text;
alter table public.stock_items add column if not exists was_price int check (was_price is null or was_price >= 0);
alter table public.stock_items add column if not exists max_qty int check (max_qty is null or max_qty between 1 and 10);

-- 2) 구매 접수
create table if not exists public.stock_orders (
  id         bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  item_id    int  not null references public.stock_items(id),
  qty        int  not null check (qty between 1 and 10),
  name       text not null check (char_length(name) between 1 and 40),
  phone      text not null check (phone ~ '^01[016789][0-9]{7,8}$'),
  status     text not null default 'pending' check (status in ('pending','confirmed','cancelled')),
  agree_privacy boolean not null check (agree_privacy)
);
create index if not exists stock_orders_item_idx on public.stock_orders (item_id);
create index if not exists stock_orders_phone_idx on public.stock_orders (phone);
alter table public.stock_orders enable row level security;

drop policy if exists "admins read stock_items" on public.stock_items;
create policy "admins read stock_items" on public.stock_items for select to authenticated using (public.is_admin());
drop policy if exists "admins read stock_orders" on public.stock_orders;
create policy "admins read stock_orders" on public.stock_orders for select to authenticated using (public.is_admin());

-- 2-1) 입금 계좌: 공개 저장소·페이지 소스에 남기지 않고, 접수에 성공한 사람에게만 place_order 응답으로 돌려준다.
--      값(account_bank / account_number / account_holder)은 SQL로 직접 넣는다. 이 파일에는 적지 않는다.
create table if not exists public.stock_settings (key text primary key, value text not null);
alter table public.stock_settings enable row level security;
revoke all on public.stock_settings from anon, authenticated;

-- 3) 남은 수량
create or replace function public.stock_left(p_item int)
returns int
language sql stable security definer set search_path = public
as $$
  select i.qty - coalesce((select sum(o.qty) from stock_orders o
                           where o.item_id = i.id and o.status in ('pending','confirmed')), 0)::int
  from stock_items i where i.id = p_item
$$;

-- 4) 방문자용 목록: 품명·연식·용도·가격·남은 수량만
create or replace function public.stock_list()
returns json
language sql stable security definer set search_path = public
as $$
  select coalesce(json_agg(json_build_object(
           'id', i.id, 'kind', i.kind, 'brand', i.brand, 'name', i.name,
           'model_year', i.model_year, 'fishing', i.fishing,
           'badge', i.badge, 'was_price', i.was_price, 'max_qty', i.max_qty,
           'price', i.price, 'left', greatest(public.stock_left(i.id), 0))
         order by i.kind desc, i.sort), '[]'::json)
  from stock_items i
$$;

-- 5) 구매 접수: 품목을 잠그고 남은 수량을 확인한 뒤 접수한다(동시에 눌러도 초과 접수되지 않음)
create or replace function public.place_order(
  p_item int, p_qty int, p_name text, p_phone text, p_agree boolean
) returns json
language plpgsql security definer set search_path = public
as $$
declare
  d text := regexp_replace(coalesce(p_phone, ''), '\D', '', 'g');
  n text := btrim(coalesce(p_name, ''));
  q int  := coalesce(p_qty, 0);
  left_now int;
  lim int;
  oid bigint;
begin
  if not coalesce(p_agree, false) then return json_build_object('ok', false, 'code', 'agree'); end if;
  if n = '' or char_length(n) > 40 then return json_build_object('ok', false, 'code', 'name'); end if;
  if d !~ '^01[016789][0-9]{7,8}$' then return json_build_object('ok', false, 'code', 'phone'); end if;
  if q < 1 or q > 10 then return json_build_object('ok', false, 'code', 'qty'); end if;
  select max_qty into lim from stock_items where id = p_item for update;
  if not found then return json_build_object('ok', false, 'code', 'item'); end if;
  if q > coalesce(lim, 10) then return json_build_object('ok', false, 'code', 'qty', 'max', coalesce(lim, 10)); end if;
  -- 한 번호로 접수 대기 중인 주문은 5건까지(장난 접수로 재고가 묶이지 않게)
  if (select count(*) from stock_orders where phone = d and status = 'pending') >= 5 then
    return json_build_object('ok', false, 'code', 'limit');
  end if;
  left_now := public.stock_left(p_item);
  if left_now < q then return json_build_object('ok', false, 'code', 'soldout', 'left', greatest(left_now, 0)); end if;
  insert into stock_orders (item_id, qty, name, phone, agree_privacy) values (p_item, q, n, d, true) returning id into oid;
  return json_build_object('ok', true, 'order', oid, 'left', left_now - q,
    'account', (select json_object_agg(replace(key, 'account_', ''), value) from stock_settings where key like 'account_%'));
end $$;

-- 6) 관리자: 접수 상태 바꾸기
--    대기 → 확정 / 대기·확정 → 취소(수량 복구) / 확정 → 대기 / 취소 → 대기(남은 수량이 있을 때만)
create or replace function public.admin_set_order(p_id bigint, p_status text)
returns json
language plpgsql security definer set search_path = public
as $$
declare o stock_orders%rowtype;
begin
  if not public.is_admin() then raise exception 'not_admin'; end if;
  select * into o from stock_orders where id = p_id for update;
  if not found then return json_build_object('ok', false, 'code', 'order'); end if;
  if o.status = p_status then return json_build_object('ok', true); end if;
  if not ((o.status = 'pending'   and p_status in ('confirmed','cancelled'))
       or (o.status = 'confirmed' and p_status in ('pending','cancelled'))
       or (o.status = 'cancelled' and p_status = 'pending')) then
    return json_build_object('ok', false, 'code', 'transition');
  end if;
  if o.status = 'cancelled' then
    perform 1 from stock_items where id = o.item_id for update;
    if public.stock_left(o.item_id) < o.qty then return json_build_object('ok', false, 'code', 'soldout'); end if;
  end if;
  update stock_orders set status = p_status, updated_at = now() where id = p_id;
  return json_build_object('ok', true);
end $$;

-- 7) 권한
revoke all on public.stock_items, public.stock_orders from anon;
revoke insert, update, delete, truncate on public.stock_items, public.stock_orders from authenticated;
grant select on public.stock_items, public.stock_orders to authenticated;
revoke execute on function public.stock_left(int) from public, anon, authenticated;
revoke execute on function public.stock_list() from public;
revoke execute on function public.place_order(int,int,text,text,boolean) from public;
revoke execute on function public.admin_set_order(bigint,text) from public, anon;
grant execute on function public.stock_list() to anon, authenticated;
grant execute on function public.place_order(int,int,text,text,boolean) to anon, authenticated;
grant execute on function public.admin_set_order(bigint,text) to authenticated;
