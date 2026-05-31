#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Configuration – fill in your Cloudflare details
# ============================================================
ZONE_NAME="mydomain.com"
RECORD_NAME="dyn.mydomain.com"
API_TOKEN="your_cloudflare_api_token"
# ============================================================

# Get current public IPv4 address
IP=$(curl -s https://ifconfig.me)

# Resolve Zone ID from zone name
ZONE_ID=$(curl -sG "https://api.cloudflare.com/client/v4/zones" \
  -H "Authorization: Bearer ${API_TOKEN}" \
  --data-urlencode "name=${ZONE_NAME}" \
  | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$ZONE_ID" ]; then
  echo "Error: could not find zone ID for ${ZONE_NAME}"
  exit 1
fi

# Look up the DNS record ID
RECORD=$(curl -sG "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records" \
  -H "Authorization: Bearer ${API_TOKEN}" \
  --data-urlencode "type=A" \
  --data-urlencode "name=${RECORD_NAME}")

RECORD_ID=$(echo "$RECORD" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$RECORD_ID" ]; then
  echo "Error: could not find DNS record for ${RECORD_NAME}"
  exit 1
fi

# Update the DNS record
RESPONSE=$(curl -s -X PUT \
  "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${RECORD_ID}" \
  -H "Authorization: Bearer ${API_TOKEN}" \
  -H "Content-Type: application/json" \
  --data "{\"type\":\"A\",\"name\":\"${RECORD_NAME}\",\"content\":\"${IP}\",\"ttl\":120,\"proxied\":false}")

if echo "$RESPONSE" | grep -q '"success":true'; then
  echo "Updated ${RECORD_NAME} -> ${IP}"
else
  echo "Failed to update DNS record:"
  echo "$RESPONSE"
  exit 1
fi
