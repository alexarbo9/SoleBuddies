const fs = require('fs');

const url = process.env.SUPABASE_URL || '';
const key = process.env.SUPABASE_PUBLISHABLE_KEY || '';
const siteOrigin = (process.env.SITE_ORIGIN || '').trim();
if (!url || !key) {
  console.error(
    'Missing SUPABASE_URL or SUPABASE_PUBLISHABLE_KEY. For CI, set GitHub Actions secrets.'
  );
  process.exit(1);
}
const cfg = { url, key };
if (siteOrigin) {
  cfg.siteOrigin = siteOrigin.replace(/\/?$/, '/');
}
fs.writeFileSync(
  'supabase-config.js',
  `window.__SOLEBUDDIES_SUPABASE = ${JSON.stringify(cfg)};\n`
);
