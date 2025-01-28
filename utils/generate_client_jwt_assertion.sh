#!/bin/bash

# --- Configuration ---
PRIVATE_KEY_FILE="rsa_key.pem"  # Path to your private key
CLIENT_ID="your_client_id"                 # Your client ID
APIGEE_HOST=""
TOKEN_ENDPOINT="https://${APIGEE_HOST}/camara/openIDConnectCIBA/v1/token"  #Authorization server token endpoint.
AUDIENCE="https://${APIGEE_HOST}" # The authorization endpoint (could also be the token endpoint)
EXPIRY_SECONDS=300                         # JWT expiry (e.g., 5 minutes)


# --- Function to check if a command exists ---
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# --- Check for required tools ---
if ! command_exists base64; then
  echo "Error: base64 is not installed. Please install the Google Cloud SDK."
  exit 1
fi

if ! command_exists openssl; then
  echo "Error: openssl is not installed."
  exit 1
fi

if ! command_exists uuidgen; then
  echo "Error: uuidgen is not installed."
  exit 1
fi

# --- JWT Header ---
HEADER=$(echo -n '{"alg":"RS256","typ":"JWT"}' | base64url)

# --- JWT Payload ---
iat=$(date +%s)
exp=$((iat + EXPIRY_SECONDS))
jti=$(uuidgen)

PAYLOAD=$(jq -n \
  --arg iss "$CLIENT_ID" \
  --arg sub "$CLIENT_ID" \
  --arg aud "$AUDIENCE" \
  --arg iat "$iat" \
  --arg exp "$exp" \
  --arg jti "$jti" \
  '{iss: $iss, sub: $sub, aud: $aud, iat: ($iat | tonumber), exp: ($exp | tonumber), jti: $jti}')

PAYLOAD_B64=$(echo -n "$PAYLOAD" | base64url)

# --- Sign the JWT ---
SIGNATURE=$(openssl dgst -sha256 -sign "$PRIVATE_KEY_FILE" <(echo -n "$HEADER.$PAYLOAD_B64") | base64url)

# --- Output the complete JWT ---
echo -n "$HEADER.$PAYLOAD_B64.$SIGNATURE"

# --- Helper function for URL-safe Base64 encoding ---
base64url() {
  base64 | tr '+/' '-_' | tr -d '='
}

exit 0