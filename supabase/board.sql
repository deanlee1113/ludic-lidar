-- 방송 릴 가격표 공유 상태(2026-11-02)
-- 방송하는 사람이 가격표에서 입력한 방송가·이전 가격·인터넷 최저가·직접 완판·남은 수량·구매자 이름을 한 줄(JSON)로 둔다.
-- 시청자 페이지(/live/)는 누구나 읽고(board_get), 쓰기는 관리자 로그인만(board_set).
create table if not exists public.board_state (
  id         text primary key,
  state      jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.board_state enable row level security;
revoke all on public.board_state from anon, authenticated;

create or replace function public.board_get(p_id text)
returns json
language sql stable security definer set search_path = public
as $$
  select coalesce(
    (select json_build_object('state', state, 'updated_at', updated_at) from board_state where id = p_id),
    json_build_object('state', '{}'::json, 'updated_at', null))
$$;

create or replace function public.board_set(p_id text, p_state jsonb)
returns json
language plpgsql security definer set search_path = public
as $$
begin
  if not public.is_admin() then raise exception 'not_admin'; end if;
  if p_id is null or char_length(p_id) > 40 then return json_build_object('ok', false, 'code', 'id'); end if;
  if jsonb_typeof(p_state) <> 'object' or octet_length(p_state::text) > 20000 then
    return json_build_object('ok', false, 'code', 'state');
  end if;
  insert into board_state (id, state, updated_at) values (p_id, p_state, now())
    on conflict (id) do update set state = excluded.state, updated_at = now();
  return json_build_object('ok', true);
end $$;

revoke execute on function public.board_get(text) from public;
revoke execute on function public.board_set(text, jsonb) from public, anon;
grant execute on function public.board_get(text) to anon, authenticated;
grant execute on function public.board_set(text, jsonb) to authenticated;
