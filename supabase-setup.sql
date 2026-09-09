-- ============================================================
-- ACHIEVEMENT WALL - SUPABASE SETUP
-- Run this entire script in Supabase SQL Editor.
-- ============================================================

create table if not exists public.achievements (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  achievement text not null check (achievement in ('Deposit', 'First Time Deposit')),
  amount numeric not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.app_config (
  id integer primary key,
  config jsonb not null,
  updated_at timestamptz not null default now()
);

insert into public.app_config (id, config)
values (1, '{
  "deposit": {"duration": 8, "confetti": true, "sound": true},
  "first_time_deposit": {"duration": 12, "confetti": true, "sound": true}
}'::jsonb)
on conflict (id) do nothing;

-- Enable RLS.
alter table public.achievements enable row level security;
alter table public.app_config enable row level security;

-- Browser clients authenticate anonymously, so they use the authenticated role.
grant select, insert, update, delete on public.achievements to authenticated;
grant select, insert, update, delete on public.app_config to authenticated;

drop policy if exists "aw achievements select" on public.achievements;
drop policy if exists "aw achievements insert" on public.achievements;
drop policy if exists "aw achievements update" on public.achievements;
drop policy if exists "aw achievements delete" on public.achievements;
create policy "aw achievements select" on public.achievements for select to authenticated using (true);
create policy "aw achievements insert" on public.achievements for insert to authenticated with check (true);
create policy "aw achievements update" on public.achievements for update to authenticated using (true) with check (true);
create policy "aw achievements delete" on public.achievements for delete to authenticated using (true);

drop policy if exists "aw config select" on public.app_config;
drop policy if exists "aw config update" on public.app_config;
drop policy if exists "aw config insert" on public.app_config;
create policy "aw config select" on public.app_config for select to authenticated using (true);
create policy "aw config update" on public.app_config for update to authenticated using (true) with check (true);
create policy "aw config insert" on public.app_config for insert to authenticated with check (true);

-- Allow authenticated clients to use the private Realtime channel.
drop policy if exists "aw realtime receive" on realtime.messages;
drop policy if exists "aw realtime send" on realtime.messages;
create policy "aw realtime receive" on realtime.messages
  for select to authenticated
  using (realtime.topic() = 'achievement-wall:CHANGE-THIS-RANDOM-VALUE');
create policy "aw realtime send" on realtime.messages
  for insert to authenticated
  with check (realtime.topic() = 'achievement-wall:CHANGE-THIS-RANDOM-VALUE');

-- IMPORTANT: after you change CHANNEL in supabase-config.js,
-- replace CHANGE-THIS-RANDOM-VALUE in the two policies above and run them again.

-- Enable Postgres Changes for achievement history synchronization.
do $$
begin
  alter publication supabase_realtime add table public.achievements;
exception
  when duplicate_object then null;
end $$;

-- Enable anonymous sign-ins in Dashboard:
-- Authentication -> Sign In / Providers -> Anonymous Sign-Ins -> Enable.

-- Enable private Realtime channels:
-- Realtime -> Settings -> turn OFF "Allow public access" if you want strict private-only channels.
