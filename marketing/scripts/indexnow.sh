#!/bin/sh
# IndexNow: instant-indexing ping for Bing / Yandex / Naver / Seznam.
# Google does NOT participate in IndexNow (May 2026) — but Bing's index
# powers ChatGPT search + DuckDuckGo, so this still has real reach.
#
# Run after every deploy that changes content.

set -e

KEY="0325d2ef1f3c51e28992f5b343647609"
HOST="getweft.xyz"

URLS='[
  "https://getweft.xyz/",
  "https://getweft.xyz/vs/dex",
  "https://getweft.xyz/vs/clay",
  "https://getweft.xyz/vs/folk",
  "https://getweft.xyz/blog/why-another-personal-crm",
  "https://getweft.xyz/about",
  "https://getweft.xyz/feedback",
  "https://getweft.xyz/feature-requests",
  "https://getweft.xyz/privacy",
  "https://getweft.xyz/terms"
]'

curl --silent --show-error --location \
  --header "Content-Type: application/json; charset=utf-8" \
  --request POST "https://api.indexnow.org/IndexNow" \
  --data "{
    \"host\": \"$HOST\",
    \"key\": \"$KEY\",
    \"keyLocation\": \"https://$HOST/$KEY.txt\",
    \"urlList\": $URLS
  }"

echo ""
echo "(IndexNow returns 200/202/204 on success — no body.)"
