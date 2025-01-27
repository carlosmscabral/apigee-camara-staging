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

if [ -z "$APIGEE_PROJECT_ID" ]; then
  echo "No APIGEE_PROJECT_ID variable set"
  exit
fi

if [ -z "$APIGEE_ENV" ]; then
  echo "No APIGEE_ENV variable set"
  exit
fi

if [ -z "$APIGEE_HOST" ]; then
  echo "No APIGEE_HOST variable set"
  exit
fi

if [ -z "$CLIENT_JKWS_URI" ]; then
  echo "No CLIENT_JKWS_URI variable set"
  exit
fi
if [ -z "$CIBA_TARGET_SERVER_URI" ]; then
  echo "No CIBA_TARGET_SERVER_URI variable set"
  exit
fi



echo "Installing apigeecli"
curl -s https://raw.githubusercontent.com/apigee/apigeecli/main/downloadLatest.sh | bash
export PATH=$PATH:$HOME/.apigeecli/bin

TOKEN=$(gcloud auth print-access-token)
gcloud config set project "$APIGEE_PROJECT_ID"

echo "Updating placeholders..."

sed -i -E "s/#APIGEE_URI_PLACEHOLDER#/${APIGEE_URI_VALUE}/g" ./apiproxy/resources/properties/ciba.properties
sed -i -E "s/#JWKS_URI_PLACEHOLDER#/${JWKS_URI_VALUE}/g" ./apiproxy/resources/properties/ciba.properties

echo "Placeholders updated successfully."

echo "Creating necessary configs..."

echo "Creating CIBA target server..."
apigeecli targetservers create --wait --name camara-oidc-ciba-backend  --org "$APIGEE_PROJECT_ID" --env "$APIGEE_ENV" --protocol HTTPS --host "$CIBA_TARGET_SERVER_URI" --token "$TOKEN"
echo "Creation of Target Server done"

echo "Deploying Apigee artifacts..."

echo "Importing and Deploying Apigee camara-oidc-ciba-v1 proxy..."
REV=$(apigeecli apis create bundle -f ./apiproxy -n camara-oidc-ciba-v1 --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check | jq ."revision" -r)
apigeecli apis deploy --wait --name camara-oidc-ciba-v1 --ovr --rev "$REV" --org "$APIGEE_PROJECT_ID" --env "$APIGEE_ENV" --token "$TOKEN"