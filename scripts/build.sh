#!/bin/sh
set -eu

: "${SUPABASE_URL:?Missing SUPABASE_URL environment variable}"
: "${SUPABASE_PUBLISHABLE_KEY:?Missing SUPABASE_PUBLISHABLE_KEY environment variable}"

# Fail the preview build on syntax errors in the interactive account panels.
node --check --input-type=module < sensuamix-admin.js
node --check --input-type=module < sensuamix-customer.js

mkdir -p public/admin public/conta
cp index.html public/index.html
cp index.html public/admin/index.html
cp index.html public/conta/index.html
cp sensuamix-customer.js public/sensuamix-customer.js
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
