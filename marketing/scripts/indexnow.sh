#!/bin/sh
# IndexNow: instant-indexing ping for Bing / Yandex / Naver / Seznam.
# Google does NOT participate in IndexNow (May 2026) — but Bing's index
# powers ChatGPT search + DuckDuckGo, so this still has real reach.
#
# Usage:  sh marketing/scripts/indexnow.sh /vs/clay /vs/dex
#         sh marketing/scripts/indexnow.sh --all        (rare; see below)
#
# Pass ONLY the paths that actually changed in this deploy. Pinging unchanged
# URLs is what gets an IndexNow key throttled, and a throttled key is useless
# on the day it matters.
#
# History: until 2026-08-15 this script took no arguments and POSTed a
# hardcoded list of 10 URLs on every run — the exact behaviour the runbook
# warns against. That list had also drifted: it missed 5 of the site's 15
# URLs (/vs, /vs/notion, /52-weeks, /press, /support). Fixed 2026-08-15.

set -e

KEY="0325d2ef1f3c51e28992f5b343647609"
HOST="getweft.xyz"

# Verified 2026-08-15: https://getweft.xyz/$KEY.txt returns 200 and its body is
# exactly $KEY. Re-check if the key is ever rotated.

usage() {
  echo "usage: $0 /path [/path ...]" >&2
  echo "       $0 --all      # every URL in sitemap.xml — only after a site-wide change" >&2
  echo "" >&2
  echo "Pass only the paths that changed. Do not ping the whole site by habit." >&2
  exit 2
}

[ $# -eq 0 ] && usage

if [ "$1" = "--all" ]; then
  [ $# -ne 1 ] && usage
  echo "Pinging EVERY URL in sitemap.xml. This should be rare." >&2
  PATHS=$(curl -sS "https://$HOST/sitemap.xml" \
            | grep -o '<loc>[^<]*' \
            | sed "s|<loc>https://$HOST||" \
            | sed 's|^$|/|')
else
  PATHS=""
  for p in "$@"; do
    case "$p" in
      /*) ;;
      *) echo "error: path must start with '/': $p" >&2; exit 2 ;;
    esac
    PATHS="$PATHS
$p"
  done
fi

# Refuse to ping anything that is not live — a 404 or a redirect in an
# IndexNow payload is worse than no ping at all.
CHECKED=""
for p in $PATHS; do
  code=$(curl -sS -o /dev/null -w '%{http_code}' "https://$HOST$p")
  if [ "$code" != "200" ]; then
    echo "error: https://$HOST$p returned $code — refusing to submit." >&2
    echo "Fix the path (or wait for it to deploy) before pinging." >&2
    exit 1
  fi
  echo "  ok 200  $p" >&2
  CHECKED="$CHECKED$p "
done

URLS=$(for p in $CHECKED; do printf '"https://%s%s",' "$HOST" "$p"; done | sed 's/,$//')

echo "" >&2
echo "Submitting $(echo $CHECKED | wc -w | tr -d ' ') URL(s) to IndexNow..." >&2

curl --silent --show-error --location \
  --header "Content-Type: application/json; charset=utf-8" \
  --request POST "https://api.indexnow.org/IndexNow" \
  --data "{
    \"host\": \"$HOST\",
    \"key\": \"$KEY\",
    \"keyLocation\": \"https://$HOST/$KEY.txt\",
    \"urlList\": [$URLS]
  }"

echo ""
echo "(IndexNow returns 200/202/204 on success — no body.)"
