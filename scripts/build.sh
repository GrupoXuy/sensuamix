#!/bin/sh
set -eu

: "${SUPABASE_URL:?Missing SUPABASE_URL environment variable}"
: "${SUPABASE_PUBLISHABLE_KEY:?Missing SUPABASE_PUBLISHABLE_KEY environment variable}"

mkdir -p public/admin
cp index.html public/index.html
cp index.html public/admin/index.html
cp sensuamix-admin.js public/sensuamix-admin.js
gzip -dc build/sensuamix-app.js.gz > public/sensuamix-app.js
gzip -dc build/sensuamix-app.css.gz > public/sensuamix-app.css

cat > public/runtime-config.js <<EOF
window.SENSUAMIX_CONFIG = Object.freeze({
  supabaseUrl: "${SUPABASE_URL}",
  publishableKey: "${SUPABASE_PUBLISHABLE_KEY}"
});
EOF

printf 'SensuaMix static build prepared for Supabase project.\n'
