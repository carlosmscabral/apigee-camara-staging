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

# ==============================================================================
# Vars for key/jwks generation
# ==============================================================================

# Prefix for the generated RSA key files.
KEY_FILE_PREFIX="rsa_key"

# ID for the generated RSA key.
KEY_ID="my-rsa-key"

# Size of the generated RSA key in bits.
KEY_SIZE=2048

# Name of the Google Cloud Storage (GCS) bucket to store the JWKS.  
# Replace with your GCS bucket name.
BUCKET_NAME="cabral-camara-jwks"  

# Location for the GCS bucket. Choose an appropriate location.
LOCATION="us-central1"  

# Filename for the JWKS JSON file. jwks.json is the default
JWKS_FILE="jwks.json"

# Name of the GCS object for the JWKS file.
GCS_OBJECT_NAME="$JWKS_FILE"

# Google Cloud Project ID where the bucket lives or will be created.
PROJECT_ID="" 


# ==============================================================================
# Vars for JWT Generation
# ==============================================================================

# --- Configuration ---

# Path to the private key file used for JWT signing.
PRIVATE_KEY_FILE="rsa_key.pem"  

# Issuer (iss) claim for the JWT.
ISS=""                 

# Subject (sub) claim for the JWT.
SUB=""

# Audience (aud) claim for the JWT.
AUD=""

# JWT expiry time in seconds.
EXPIRY_SECONDS=300                         

# --- Custom Claims ---
# Add custom claims to the JWT."
# Example: CUSTOM_CLAIM_ROLE="admin" will add the role custom claim to the JWT.
# Add your custom claims below.

#Example of Login Hint
CUSTOM_CLAIM_login_hint="+55123456789"

# Add more custom claims as needed...
