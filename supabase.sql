-- ============================================================
-- 把這整份貼到 Supabase 的 SQL Editor 執行（只要做一次）
-- 執行前：把下面的 你的信箱@example.com 換成你自己的登入信箱（共 2 處）
-- ============================================================

-- 1) 網站內容（所有人可讀，只有站長可寫）
create table if not exists public.site (
  id int primary key,
  data jsonb not null,
  updated_at timestamptz default now()
);

-- 2) 留言（訪客不能直接讀取，只能透過下面兩個函式）
create table if not exists public.messages (
  id bigint generated always as identity primary key,
  thread uuid not null,
  name text not null default '匿名',
  body text not null,
  from_owner boolean not null default false,
  created_at timestamptz not null default now()
);
create index if not exists messages_thread_idx on public.messages(thread);

alter table public.site enable row level security;
alter table public.messages enable row level security;

drop policy if exists "site_read" on public.site;
create policy "site_read" on public.site for select using (true);

drop policy if exists "site_owner_write" on public.site;
create policy "site_owner_write" on public.site for all to authenticated
  using ((auth.jwt() ->> 'email') = '你的信箱@example.com')
  with check ((auth.jwt() ->> 'email') = '你的信箱@example.com');

-- 訪客對 messages 沒有任何直接權限；站長（指定信箱）可以讀、回覆、刪除
drop policy if exists "msg_owner_all" on public.messages;
create policy "msg_owner_all" on public.messages for all to authenticated
  using ((auth.jwt() ->> 'email') = '你的信箱@example.com')
  with check ((auth.jwt() ->> 'email') = '你的信箱@example.com');

-- 3) 訪客送出留言（有長度限制，每個訪客每小時最多 10 則）
create or replace function public.post_message(p_token uuid, p_name text, p_body text)
returns void language plpgsql security definer set search_path = public as $$
begin
  if p_body is null or length(trim(p_body)) = 0 or length(p_body) > 1000 then
    raise exception 'invalid message';
  end if;
  if (select count(*) from messages
      where thread = p_token and not from_owner
        and created_at > now() - interval '1 hour') >= 10 then
    raise exception 'too many messages';
  end if;
  insert into messages(thread, name, body)
  values (p_token, left(coalesce(nullif(trim(p_name), ''), '匿名'), 30), p_body);
end $$;

-- 4) 訪客讀取「自己的」對話（用只有他知道的隨機代碼，看不到別人的）
create or replace function public.get_thread(p_token uuid)
returns table(id bigint, name text, body text, from_owner boolean, created_at timestamptz)
language sql security definer set search_path = public as $$
  select id, name, body, from_owner, created_at
  from messages where thread = p_token order by created_at
$$;

grant execute on function public.post_message(uuid, text, text) to anon, authenticated;
grant execute on function public.get_thread(uuid) to anon, authenticated;
