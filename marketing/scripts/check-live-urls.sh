#!/bin/sh
# Post-deploy check: every URL in the live sitemap must return a clean 200.
#
# Usage:  sh marketing/scripts/check-live-urls.sh [https://getweft.xyz]
#
# Ten seconds, and it has already caught two real bugs that were invisible in
# Search Console's summary:
#   2026-08-12  /vs/ in the sitemap 308'd to /vs (trailingSlash: false)
#   2026-08-14  44 internal href="index.html" links 308'd to /
#
# Exits non-zero if any sitemap URL is not a clean 200, or if the sitemap is
# empty or unparseable.
#
# Gotcha this script exists to prevent: an earlier manual version wrote its URL
# list to a fixed /tmp path. A previous run's file survived a failed write and
# produced a convincing false positive. Always a fresh mktemp -d.

set -eu

HOST="${1:-https://getweft.xyz}"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

echo "Fetching $HOST/sitemap.xml"
curl -sS --fail "$HOST/sitemap.xml" > "$TMP/sitemap.xml"

grep -o '<loc>[^<]*' "$TMP/sitemap.xml" | sed 's|<loc>||' > "$TMP/urls.txt"

COUNT=$(grep -c . "$TMP/urls.txt" || true)
if [ "$COUNT" -eq 0 ]; then
  echo "FAIL: sitemap contains no <loc> entries" >&2
  exit 1
fi
echo "$COUNT URLs in sitemap"
echo ""

FAILED=0
while IFS= read -r url; do
  [ -z "$url" ] && continue
  # No -L: a redirect must show as a redirect rather than being silently
  # followed to a 200. Redirects in a sitemap are the bug being hunted.
  result=$(curl -sS -o /dev/null -w '%{http_code} %{redirect_url}' "$url")
  code=${result%% *}
  redirect=${result#* }
  if [ "$code" = "200" ]; then
    printf '  200  %s\n' "$url"
  else
    printf '  %-3s  %s  -> %s\n' "$code" "$url" "$redirect"
    FAILED=$((FAILED + 1))
  fi
done < "$TMP/urls.txt"

echo ""
if [ "$FAILED" -eq 0 ]; then
  echo "PASS: $COUNT/$COUNT return 200, no redirects."
else
  echo "FAIL: $FAILED of $COUNT did not return a clean 200." >&2
  exit 1
fi
