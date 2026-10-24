-- Pixel Workshop RPG Maker. Run in the connected Supabase project.
-- Existing site/messages tables are untouched.
create table if not exists public.rpg_projects (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  title text not null default '未命名遊戲',
  data jsonb not null,
  updated_at timestamptz not null default now()
);
create index if not exists rpg_projects_owner_updated_idx on public.rpg_projects(owner_id,updated_at desc);
alter table public.rpg_projects enable row level security;
grant select,insert,update,delete on public.rpg_projects to authenticated;
drop policy if exists rpg_projects_select_own on public.rpg_projects;
create policy rpg_projects_select_own on public.rpg_projects for select to authenticated
  using ((select auth.uid())=owner_id);
drop policy if exists rpg_projects_insert_own on public.rpg_projects;
create policy rpg_projects_insert_own on public.rpg_projects for insert to authenticated
  with check ((select auth.uid())=owner_id);
drop policy if exists rpg_projects_update_own on public.rpg_projects;
create policy rpg_projects_update_own on public.rpg_projects for update to authenticated
  using ((select auth.uid())=owner_id) with check ((select auth.uid())=owner_id);
drop policy if exists rpg_projects_delete_own on public.rpg_projects;
create policy rpg_projects_delete_own on public.rpg_projects for delete to authenticated
  using ((select auth.uid())=owner_id);

create table if not exists public.rpg_publications (
  id uuid primary key references public.rpg_projects(id) on delete cascade,
  owner_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  data jsonb not null,
  published_at timestamptz not null default now()
);
alter table public.rpg_publications enable row level security;
grant select on public.rpg_publications to anon, authenticated;
grant insert,update,delete on public.rpg_publications to authenticated;
drop policy if exists rpg_publications_read on public.rpg_publications;
create policy rpg_publications_read on public.rpg_publications for select to anon,authenticated using (true);
drop policy if exists rpg_publications_insert_own on public.rpg_publications;
create policy rpg_publications_insert_own on public.rpg_publications for insert to authenticated
  with check ((select auth.uid())=owner_id and exists
    (select 1 from public.rpg_projects p where p.id=rpg_publications.id and p.owner_id=(select auth.uid())));
drop policy if exists rpg_publications_update_own on public.rpg_publications;
create policy rpg_publications_update_own on public.rpg_publications for update to authenticated
  using ((select auth.uid())=owner_id) with check ((select auth.uid())=owner_id and exists
    (select 1 from public.rpg_projects p where p.id=rpg_publications.id and p.owner_id=(select auth.uid())));
drop policy if exists rpg_publications_delete_own on public.rpg_publications;
create policy rpg_publications_delete_own on public.rpg_publications for delete to authenticated
  using ((select auth.uid())=owner_id);

insert into storage.buckets(id,name,public,file_size_limit)
values ('rpg-assets','rpg-assets',true,20971520)
on conflict (id) do nothing;
drop policy if exists rpg_assets_insert_own on storage.objects;
create policy rpg_assets_insert_own on storage.objects for insert to authenticated
  with check (bucket_id='rpg-assets' and (storage.foldername(name))[1]=(select auth.uid())::text);
drop policy if exists rpg_assets_delete_own on storage.objects;
create policy rpg_assets_delete_own on storage.objects for delete to authenticated
  using (bucket_id='rpg-assets' and owner_id=(select auth.uid())::text);

