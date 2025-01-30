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

# --- Configuration ---


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

# --- Check for required tools ---
if ! command_exists gsutil; then
  echo "Error: gsutil is not installed. Please install the Google Cloud SDK."
  exit 1
fi

if ! command_exists openssl; then
  echo "Error: openssl is not installed."
  exit 1
fi


check_env_var PROJECT_ID
check_env_var KEY_FILE_PREFIX
check_env_var KEY_ID
check_env_var KEY_SIZE
check_env_var BUCKET_NAME
check_env_var LOCATION
check_env_var JWKS_FILE
check_env_var GCS_OBJECT_NAME



# --- Check if the bucket exists ---
if ! gsutil ls -b "gs://${BUCKET_NAME}" 2>/dev/null; then
  echo "Bucket '$BUCKET_NAME' does not exist. Creating it..."

  # --- Create the bucket with uniform bucket-level access ---
  gsutil mb -p "$PROJECT_ID" -l "$LOCATION" -b on "gs://${BUCKET_NAME}"

  if [ $? -ne 0 ]; then
    echo "Error: Failed to create bucket '$BUCKET_NAME'."
    exit 1
  fi

  echo "Bucket '$BUCKET_NAME' created successfully."
fi

# --- Grant public read access at the BUCKET level using IAM ---
gsutil iam ch allUsers:objectViewer "gs://${BUCKET_NAME}"

# --- Generate RSA Private Key ---
openssl genpkey -algorithm RSA -out "${KEY_FILE_PREFIX}.pem" -pkeyopt rsa_keygen_bits:"$KEY_SIZE"

# --- Generate RSA Public Key ---
openssl rsa -pubout -in "${KEY_FILE_PREFIX}.pem" -out "${KEY_FILE_PREFIX}_pub.pem"

# --- Extract Public Key Components (n, e) for JWKS ---
MODULUS_DEC=$(openssl rsa -in "${KEY_FILE_PREFIX}.pem" -noout -modulus | sed 's/Modulus=//')
EXPONENT_DEC=$(openssl rsa -in "${KEY_FILE_PREFIX}.pem" -noout -pubin -text | grep Public-Key: | awk '{print $2}' | cut -d '(' -f2 | cut -d ' ' -f1)
MODULUS_B64=$(echo -n "$MODULUS_DEC" | xxd -r -p | base64 | tr '+/' '-_' | tr -d '=')
EXPONENT_B64=$(echo -n "$EXPONENT_DEC" | xxd -r -p | base64 | tr '+/' '-_' | tr -d '=')

# --- Create JWKS JSON ---
cat <<EOF > "$JWKS_FILE"
{
  "keys": [
    {
      "kty": "RSA",
      "n": "$MODULUS_B64",
      "e": "$EXPONENT_B64",
      "kid": "$KEY_ID",
      "alg": "RS256"
    }
  ]
}
EOF

# --- Upload JWKS to GCS ---
gsutil cp "$JWKS_FILE" "gs://${BUCKET_NAME}/${GCS_OBJECT_NAME}"

# --- Construct and print the public URL ---
PUBLIC_URL="https://storage.googleapis.com/${BUCKET_NAME}/${GCS_OBJECT_NAME}"
echo "JWKS Public URL: $PUBLIC_URL"

echo "Private Key: ${KEY_FILE_PREFIX}.pem"
echo "Public Key: ${KEY_FILE_PREFIX}_pub.pem"

exit 0