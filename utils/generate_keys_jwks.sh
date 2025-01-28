#!/bin/bash

# --- Configuration ---
KEY_FILE_PREFIX="rsa_key"
KEY_ID="my-rsa-key"
KEY_SIZE=2048
BUCKET_NAME="cabral-camara-jwks"  # Replace with your GCS bucket name
JWKS_FILE="jwks.json"
GCS_OBJECT_NAME="jwks.json"
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    echo "Error: Could not determine active GCP project. Please set it manually:"
    read -r -p "Enter your GCP project ID: " PROJECT_ID
    if [ -z "$PROJECT_ID" ]; then
        echo "Error: Project ID is required."
        exit 1
    fi
fi
LOCATION="us-central1"  # Choose an appropriate location

# --- Function to check if a command exists ---
command_exists() {
  command -v "$1" >/dev/null 2>&1
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