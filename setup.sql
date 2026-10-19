-- TAKEBOOK ADMIN: run in Supabase SQL Editor.
-- This creates a clean `books` table for the new admin panel. It does NOT alter or delete the existing `BookProduct` table.

create extension if not exists pgcrypto;

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'admin' check (role = 'admin'),
  created_at timestamptz not null default now()
);

create table if not exists public.books (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  author text not null,
  category text not null default 'Khác',
  price integer not null default 0 check (price >= 0),
  stock integer not null default 0 check (stock >= 0),
  isbn text unique,
  description text,
  image_url text,
  image_path text,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists books_title_idx on public.books using gin (to_tsvector('simple', coalesce(title,'')));
create index if not exists books_author_idx on public.books (author);
create index if not exists books_category_idx on public.books (category);
create index if not exists books_published_created_idx on public.books (is_published, created_at desc);

create or replace function public.is_takebook_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.admin_users
    where user_id = (select auth.uid()) and role = 'admin'
  );
$$;
revoke all on function public.is_takebook_admin() from public;
grant execute on function public.is_takebook_admin() to authenticated;

alter table public.admin_users enable row level security;
alter table public.books enable row level security;
revoke all on public.admin_users from anon, authenticated;
grant select on public.admin_users to authenticated;
grant select, insert, update, delete on public.books to anon, authenticated;

drop policy if exists "admins can read own admin row" on public.admin_users;
create policy "admins can read own admin row" on public.admin_users
for select to authenticated using (user_id = (select auth.uid()));

drop policy if exists "public can read published books" on public.books;
create policy "public can read published books" on public.books
for select to anon, authenticated using (is_published = true or public.is_takebook_admin());

drop policy if exists "admins can insert books" on public.books;
create policy "admins can insert books" on public.books
for insert to authenticated with check (public.is_takebook_admin());

drop policy if exists "admins can update books" on public.books;
create policy "admins can update books" on public.books
for update to authenticated using (public.is_takebook_admin()) with check (public.is_takebook_admin());

drop policy if exists "admins can delete books" on public.books;
create policy "admins can delete books" on public.books
for delete to authenticated using (public.is_takebook_admin());

-- Public read for book-cover URLs; only authenticated TakeBook admins may upload/change/delete.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('book-covers', 'book-covers', true, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public = true, file_size_limit = 5242880, allowed_mime_types = array['image/jpeg','image/png','image/webp'];

drop policy if exists "takebook public can view book covers" on storage.objects;
create policy "takebook public can view book covers" on storage.objects
for select to anon, authenticated using (bucket_id = 'book-covers');

drop policy if exists "takebook admins upload book covers" on storage.objects;
create policy "takebook admins upload book covers" on storage.objects
for insert to authenticated with check (bucket_id = 'book-covers' and public.is_takebook_admin());

drop policy if exists "takebook admins update book covers" on storage.objects;
create policy "takebook admins update book covers" on storage.objects
for update to authenticated using (bucket_id = 'book-covers' and public.is_takebook_admin()) with check (bucket_id = 'book-covers' and public.is_takebook_admin());

drop policy if exists "takebook admins delete book covers" on storage.objects;
create policy "takebook admins delete book covers" on storage.objects
for delete to authenticated using (bucket_id = 'book-covers' and public.is_takebook_admin());

-- After creating the first admin user in Supabase Authentication > Users, copy that user's UUID
-- and run this separately (replace UUID; do not put it in website code):
-- insert into public.admin_users (user_id, role) values ('PASTE-AUTH-USER-UUID-HERE', 'admin') on conflict (user_id) do nothing;
