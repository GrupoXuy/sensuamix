#!/bin/sh
set -eu

: "${SUPABASE_URL:?Missing SUPABASE_URL environment variable}"
: "${SUPABASE_PUBLISHABLE_KEY:?Missing SUPABASE_PUBLISHABLE_KEY environment variable}"

# Fetch approved media archive and validate its exact checksum before extraction.
MEDIA_ARCHIVE_URL="https://d2ol7oe51mr4n9.cloudfront.net/user_3Jf2YO0hRUCBLBIs4WCkhFENfrz/a5da9f1f-98eb-46b4-8b7d-57454f776ab3.zip"
MEDIA_ARCHIVE_SHA256="31419d587f01f0dd53b0cbe7a07cb800725d9c64a84164591af732f964d6ca9c"
MEDIA_ARCHIVE="$(mktemp)"
trap 'rm -f "$MEDIA_ARCHIVE"' EXIT

curl --fail --silent --show-error --location --retry 3 --connect-timeout 10 --max-time 90 "$MEDIA_ARCHIVE_URL" -o "$MEDIA_ARCHIVE"
printf '%s  %s\n' "$MEDIA_ARCHIVE_SHA256" "$MEDIA_ARCHIVE" | sha256sum --check --status

# Guard the build against script and configuration regressions.
node --check --input-type=module < sensuamix-admin.js
node --check --input-type=module < sensuamix-customer.js
sh -n scripts/build.sh

mkdir -p public/admin public/conta public/videos public/images
cp index.html public/index.html
cp index.html public/admin/index.html
cp index.html public/conta/index.html
cp sensuamix-customer.js public/sensuamix-customer.js
cp sensuamix-admin.js public/sensuamix-admin.js
gzip -dc build/sensuamix-app.js.gz > public/sensuamix-app.js
gzip -dc build/sensuamix-app.css.gz > public/sensuamix-app.css

# Extract only the four intended public media assets. Never unpack the archive wholesale.
unzip -p "$MEDIA_ARCHIVE" "SensuaMix-Suh-integrado/public/videos/suh-entrance.mp4" > public/videos/suh-entrance.mp4
unzip -p "$MEDIA_ARCHIVE" "SensuaMix-Suh-integrado/public/videos/suh-entrance.webm" > public/videos/suh-entrance.webm
unzip -p "$MEDIA_ARCHIVE" "SensuaMix-Suh-integrado/public/videos/suh-preview.gif" > public/videos/suh-preview.gif
unzip -p "$MEDIA_ARCHIVE" "SensuaMix-Suh-integrado/public/images/suh-final.png" > public/images/suh-final.png

test -s public/videos/suh-entrance.mp4
test -s public/videos/suh-entrance.webm
test -s public/videos/suh-preview.gif
test -s public/images/suh-final.png

cat > public/runtime-config.js <<EOF
window.SENSUAMIX_CONFIG = Object.freeze({
  supabaseUrl: "${SUPABASE_URL}",
  publishableKey: "${SUPABASE_PUBLISHABLE_KEY}"
});
EOF

printf 'SensuaMix build passed; Suh media archive checksum verified.\n'
