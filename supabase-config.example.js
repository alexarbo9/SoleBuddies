// Copy to supabase-config.js for local/dev (that file is gitignored).
// Project URL + Publishable key: Supabase → Settings → API Keys.

window.__SOLEBUDDIES_SUPABASE = {
  url: 'https://YOUR_PROJECT_REF.supabase.co',
  key: 'sb_publishable_YOUR_KEY_HERE',
  // Optional: force magic-link return URL (GitHub Actions sets this for prod). Omit for local dev.
  // siteOrigin: 'https://YOUR_USER.github.io/YOUR_REPO/'
};
