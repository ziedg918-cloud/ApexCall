# Achievement Wall — Cloud / Supabase Edition

This version removes the dependency on the Wall PC's local IP address.

## Architecture

Admin PC / phone -> Supabase Realtime -> Wall PC browser

The Wall PC only needs internet access. DHCP/static IP is no longer relevant to the celebration command.

## Files

- `wall.html` — celebration screen for the music/display PC
- `phone.html` — controller for phone
- `admin.html` — admin dashboard + configuration + history
- `supabase-config.js` — YOUR Supabase URL, publishable key and private channel name
- `supabase-client.js` — common Supabase/Reatime code
- `supabase-setup.sql` — database/RLS setup
- `start_local.bat` — optional local test server
- `static/` — existing assets
- `legacy-*.html` — backups of your original pages

## Important

Do NOT put a `sb_secret_...` or old `service_role` key in the browser. Use the Supabase Publishable key (`sb_publishable_...`) from the Project Connect/API Keys screen.

## Setup

1. Create a Supabase project.
2. Enable Authentication -> Anonymous Sign-Ins.
3. Open SQL Editor and run `supabase-setup.sql`.
4. Choose a random channel name, e.g. `achievement-wall:office-7f3a91d2`.
5. Put that same channel name into `supabase-config.js` and replace the channel string in the two Realtime policies in the SQL file, then run those two policy statements again.
6. Put your Project URL and Publishable key into `supabase-config.js`.
7. For testing on the Wall PC, run `start_local.bat`, then open `http://localhost:8080/wall.html`.
8. Open `http://localhost:8080/phone.html` on the phone or `admin.html` on another PC for testing. This local test requires the devices to be able to access the hosted version; for a real office setup, deploy this folder to a static web host.

## Recommended production deployment

Put these files in a GitHub repository and enable GitHub Pages (or use another static host). After deployment, use the public HTTPS URL:

- `https://YOUR-SITE/wall.html`
- `https://YOUR-SITE/admin.html`
- `https://YOUR-SITE/phone.html`

Bookmark `wall.html` on the music PC and put the site in browser full-screen/kiosk mode.

## Security note

This first cloud version uses anonymous Supabase users and authenticated RLS. It is much safer than putting a database secret in the browser, but all anonymous users of the deployed site are allowed to use the app tables/channel. For a stricter production setup, the next step is to add a real admin login and a wall/device registration table so only authorized admins can send celebrations.

## Restore history from the old Flask project

Your old project stored achievements in `achievements.json`. The four existing records have been preserved in `migrate-old-history.sql`.

After running `supabase-setup.sql`, open Supabase SQL Editor, open `migrate-old-history.sql`, and click Run once. Then refresh `wall.html`. The old achievements will appear in the Wall history.

The old JSON did not contain dates/times, so Supabase will assign `created_at` when these records are imported. Names, achievement types, amounts, and original IDs are preserved.
