-- ============================================================
-- ACHIEVEMENT WALL - SECURITY HARDENING
-- Run this in the Supabase SQL Editor AFTER supabase-setup.sql
-- and v2-setup.sql have already been run.
--
-- What this changes:
--   - wall.html keeps working exactly as before: anyone can open
--     it, no login, and it can still READ achievements/config and
--     RECEIVE celebration broadcasts.
--   - Every WRITE (insert/update/delete on achievements, agents,
--     walls, app_config) and every celebration broadcast SEND now
--     requires a REAL logged-in admin account, not just any
--     anonymous Supabase session. Anonymous sessions still exist
--     (the wall uses one) but can no longer write anything.
--
-- Before running this, create at least one real admin account:
--   Supabase Dashboard -> Authentication -> Users -> Add user
--   (set an email + password, and confirm the email if required).
-- That email/password is what you'll type into the login screen
-- on admin.html / dashboard.html / phone.html.
-- ============================================================

-- ---------- achievements ----------

drop policy if exists "aw achievements insert" on public.achievements;
drop policy if exists "aw achievements update" on public.achievements;
drop policy if exists "aw achievements delete" on public.achievements;

create policy "aw achievements insert" on public.achievements
  for insert to authenticated
  with check (coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false) = false);

create policy "aw achievements update" on public.achievements
  for update to authenticated
  using (coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false) = false)
  with check (coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false) = false);

create policy "aw achievements delete" on public.achievements
  for delete to authenticated
  using (coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false) = false);

-- "aw achievements select" is left untouched: wall.html, phone.html
-- and admin pages all still need to read history.


-- ---------- app_config ----------

drop policy if exists "aw config update" on public.app_config;
drop policy if exists "aw config insert" on public.app_config;

create policy "aw config update" on public.app_config
  for update to authenticated
  using (coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false) = false)
  with check (coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false) = false);

create policy "aw config insert" on public.app_config
  for insert to authenticated
  with check (coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false) = false);


-- ---------- agents (V2) ----------

drop policy if exists "aw agents insert" on public.agents;
drop policy if exists "aw agents update" on public.agents;
drop policy if exists "aw agents delete" on public.agents;

create policy "aw agents insert" on public.agents
  for insert to authenticated
  with check (coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false) = false);

create policy "aw agents update" on public.agents
  for update to authenticated
  using (coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false) = false)
  with check (coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false) = false);

create policy "aw agents delete" on public.agents
  for delete to authenticated
  using (coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false) = false);


-- ---------- walls (V2) ----------

drop policy if exists "aw walls insert" on public.walls;
drop policy if exists "aw walls update" on public.walls;
drop policy if exists "aw walls delete" on public.walls;

create policy "aw walls insert" on public.walls
  for insert to authenticated
  with check (coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false) = false);

create policy "aw walls update" on public.walls
  for update to authenticated
  using (coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false) = false)
  with check (coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false) = false);

create policy "aw walls delete" on public.walls
  for delete to authenticated
  using (coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false) = false);


-- ---------- Realtime channel ----------
-- The wall only ever needs to RECEIVE broadcasts (new_achievement,
-- stop_celebration, etc). Only a real admin should be able to SEND
-- one (which is what phone.html / admin.html / dashboard.html do
-- when triggering or stopping a celebration).

drop policy if exists "aw realtime send" on realtime.messages;

create policy "aw realtime send" on realtime.messages
  for insert to authenticated
  with check (
    realtime.topic() = 'achievement-wall:apexc-2026'
    and coalesce((auth.jwt() ->> 'is_anonymous')::boolean, false) = false
  );

-- "aw realtime receive" (select) is left untouched: wall.html keeps
-- receiving broadcasts anonymously, with no login.
