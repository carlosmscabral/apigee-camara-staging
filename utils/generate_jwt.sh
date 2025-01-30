#!/bin/bash

# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.



# --- Function to check if a command exists ---
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check for required environment variables
check_env_var() {
  var_name="$1"
  if [ -z "${!var_name}" ]; then
    echo "Error: Environment variable $var_name is not set."
    exit 1
  fi
}

# --- Helper function for URL-safe Base64 encoding ---
base64url() {
  base64 | tr '+/' '-_' | tr -d '='
}

# --- Check for required tools ---
if ! command_exists base64; then
  echo "Error: base64 is not installed. "
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

if ! command_exists jq; then
  echo "Error: jq is not installed."
  exit 1
fi

check_env_var PRIVATE_KEY_FILE
check_env_var EXPIRY_SECONDS


# --- JWT Header ---
HEADER=$(echo -n '{"alg":"RS256","typ":"JWT"}' | base64url)

# --- JWT Payload ---
iat=$(date +%s)
exp=$((iat + EXPIRY_SECONDS))
jti=$(uuidgen)

# Build the custom claims part of the payload
CUSTOM_CLAIMS_JSON=$(
  for CLAIM in $(compgen -A variable); do
    if [[ "$CLAIM" == CUSTOM_CLAIM_* ]]; then
      CLAIM_NAME="${CLAIM//CUSTOM_CLAIM_/}"
      VALUE=$(eval "echo \"\$$CLAIM\"")
      jq -n --arg name "$CLAIM_NAME" --arg value "$VALUE" '{($name): $value}'
    fi
  done | jq -s 'add'
)

PAYLOAD=$(jq -n \
  --arg iss "$ISS" \
  --arg sub "$SUB" \
  --arg aud "$AUD" \
  --arg iat "$iat" \
  --arg exp "$exp" \
  --arg jti "$jti" \
  --argjson custom "$CUSTOM_CLAIMS_JSON" \
  '{iss: $iss, sub: $sub, aud: $aud, iat: ($iat | tonumber), exp: ($exp | tonumber), jti: $jti} + $custom'
)

PAYLOAD_B64=$(echo -n "$PAYLOAD" | base64url)

# --- Sign the JWT ---
SIGNATURE=$(openssl dgst -sha256 -sign "$PRIVATE_KEY_FILE" <(echo -n "$HEADER.$PAYLOAD_B64") | base64url)

# --- Output the complete JWT ---
echo -n "$HEADER.$PAYLOAD_B64.$SIGNATURE"

exit 0