// Copy to supabase-config.js for local/dev (that file is gitignored).
// Project URL + Publishable key: Supabase → Settings → API Keys.
//
// Magic links: set siteOrigin for production (below). In Supabase Dashboard go to
// Authentication → URL Configuration and add that URL to Redirect URLs (e.g.
// https://YOUR_USER.github.io/YOUR_REPO/** ). If prod is missing, Supabase falls
// back to “Site URL” (often localhost), so the email link points at localhost.

window.__SOLEBUDDIES_SUPABASE = {
  url: 'https://YOUR_PROJECT_REF.supabase.co',
  key: 'sb_publishable_YOUR_KEY_HERE',
  // Optional: force magic-link return URL (GitHub Actions sets this for prod). Omit for local dev.
  // siteOrigin: 'https://YOUR_USER.github.io/YOUR_REPO/'
};
