# Achievement Wall 2.0 — Gamification Edition

This version keeps the existing Wall/Phone/Admin pages and adds a cloud dashboard with agents, walls, leaderboard, statistics, themes, and expanded achievement types.

## Technology
- HTML/CSS/JavaScript
- Supabase Auth (anonymous prototype)
- Supabase PostgreSQL
- Supabase Realtime Broadcast/Postgres Changes
- Browser-only architecture; no static IP and no Flask server required

## Setup
1. Open your existing Supabase project.
2. Make sure the old `supabase-setup.sql` and old-history migration were already run.
3. Open `v2-setup.sql` in Supabase SQL Editor and click Run.
4. Keep the same `supabase-config.js` values you already use. Do not put a secret/service_role key in it.
5. Open `dashboard.html` to manage agents, walls, achievements and settings.
6. Open `wall.html` on the music/display PC.
7. Open `phone.html` on a phone if you still want the simple controller.

## New dashboard
- Overview statistics
- Monthly leaderboard
- Recent achievements
- Create/celebrate achievement
- Agent management
- Wall registry
- Full achievement history
- Celebration duration settings

## New database tables
- `agents`
- `walls`

Existing `achievements` rows are automatically linked to agents and the first wall by `v2-setup.sql`.

## Important security note
This is still an internal prototype using anonymous Supabase users. For real company deployment, add permanent admin authentication and tighten RLS before allowing public access. Never put a Supabase secret/service_role key in browser code.
