-- ACHIEVEMENT WALL 2.0 - GAMIFICATION UPGRADE
-- Run AFTER your existing supabase-setup.sql and migration SQL.

create table if not exists public.agents (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  team text default 'General',
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.walls (
  id uuid primary key default gen_random_uuid(),
  wall_code text not null unique,
  name text not null,
  team text default 'General',
  active boolean not null default true,
  last_seen_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.achievements add column if not exists agent_id uuid references public.agents(id) on delete set null;
alter table public.achievements add column if not exists wall_id uuid references public.walls(id) on delete set null;
alter table public.achievements add column if not exists theme text not null default 'gold';

-- The original project allowed only two types. V2 adds common gamification types.
alter table public.achievements drop constraint if exists achievements_achievement_check;
alter table public.achievements add constraint achievements_achievement_check
  check (achievement in (
    'Deposit', 'First Time Deposit', 'Biggest Deposit', 'Daily Target Reached',
    'Weekly Target', 'Monthly Top Performer', 'Personal Target Reached',
    '5 Deposits Streak', 'VIP Customer', 'Team Target Reached', 'Custom'
  ));

create index if not exists achievements_created_at_idx on public.achievements(created_at desc);
create index if not exists achievements_agent_idx on public.achievements(agent_id);
create index if not exists achievements_wall_idx on public.achievements(wall_id);

alter table public.agents enable row level security;
alter table public.walls enable row level security;

-- V2 is designed for the current anonymous-auth prototype. Tighten these policies when
-- you add permanent admin accounts in the next security phase.
grant select, insert, update, delete on public.agents to authenticated;
grant select, insert, update, delete on public.walls to authenticated;

drop policy if exists "aw agents select" on public.agents;
drop policy if exists "aw agents insert" on public.agents;
drop policy if exists "aw agents update" on public.agents;
drop policy if exists "aw agents delete" on public.agents;
create policy "aw agents select" on public.agents for select to authenticated using (true);
create policy "aw agents insert" on public.agents for insert to authenticated with check (true);
create policy "aw agents update" on public.agents for update to authenticated using (true) with check (true);
create policy "aw agents delete" on public.agents for delete to authenticated using (true);

drop policy if exists "aw walls select" on public.walls;
drop policy if exists "aw walls insert" on public.walls;
drop policy if exists "aw walls update" on public.walls;
drop policy if exists "aw walls delete" on public.walls;
create policy "aw walls select" on public.walls for select to authenticated using (true);
create policy "aw walls insert" on public.walls for insert to authenticated with check (true);
create policy "aw walls update" on public.walls for update to authenticated using (true) with check (true);
create policy "aw walls delete" on public.walls for delete to authenticated using (true);

-- Seed agents from existing history, without duplicating names.
insert into public.agents(name)
select distinct trim(name) from public.achievements
where trim(name) <> ''
on conflict (name) do nothing;

-- Create the first wall record. You can rename it from the dashboard.
insert into public.walls(wall_code, name, team)
values ('WALL-01', 'Main Achievement Wall', 'General')
on conflict (wall_code) do nothing;

-- Backfill agent_id for existing achievements.
update public.achievements a
set agent_id = ag.id
from public.agents ag
where a.agent_id is null and lower(trim(a.name)) = lower(trim(ag.name));

-- Backfill a wall for existing history.
update public.achievements a
set wall_id = w.id
from public.walls w
where a.wall_id is null and w.wall_code = 'WALL-01';

-- Realtime: the achievements table is already added by the original setup.
-- Presence is handled client-side through the Realtime channel.
