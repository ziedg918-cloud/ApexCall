-- ============================================================
-- RESTORE OLD ACHIEVEMENT WALL HISTORY
-- Source: the old achievements.json from the Flask project.
-- Run this ONCE in Supabase SQL Editor after supabase-setup.sql.
-- ============================================================

insert into public.achievements (id, name, achievement, amount)
values
  ('4944415b-34bd-49b0-b6f0-de3251e1b2e5', 'Sarah Sa', 'Deposit', 200),
  ('7b0da10e-d182-4bb7-8960-ea942595eed0', 'Aziz Ch', 'Deposit', 250),
  ('77809032-03c9-42b6-b5c5-a402fdc9c975', 'Asmae Na', 'Deposit', 200),
  ('a4b58e6e-f3ec-48af-86df-c6119e9cd762', 'Juliette Ma', 'Deposit', 250)
on conflict (id) do nothing;

-- Check the restored history:
select id, name, achievement, amount, created_at
from public.achievements
order by created_at asc;
