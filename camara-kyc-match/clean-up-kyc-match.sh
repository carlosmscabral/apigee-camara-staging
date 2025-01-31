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
# Pre-Setup: Environment Checks and Tool Installation
# ==============================================================================

PROXY_NAME=camara-kyc-match-v1
# MOCK_PROXY_NAME=camara-kyc-match-mock-backend-v1
TARGET_SERVER_NAME=camara-kyc-match

# Check for required environment variables
check_env_var() {
  var_name="$1"
  if [ -z "${!var_name}" ]; then
    echo "Error: Environment variable $var_name is not set."
    exit 1
  fi
}

check_env_var APIGEE_PROJECT_ID
check_env_var APIGEE_ENV
# check_env_var USE_MOCK

echo "Installing apigeecli..."
curl -s https://raw.githubusercontent.com/apigee/apigeecli/main/downloadLatest.sh | bash
export PATH="$PATH:$HOME/.apigeecli/bin"

# Get Google Cloud access token
TOKEN=$(gcloud auth print-access-token) || { echo "Error: Could not get Google Cloud access token."; exit 1; }
gcloud config set project "$APIGEE_PROJECT_ID" || { echo "Error: Could not set Google Cloud project."; exit 1; }


# ==============================================================================
# DELETE Actions
# ==============================================================================

echo "Undeploying ${PROXY_NAME} proxy"
REV=$(apigeecli envs deployments get --env "$APIGEE_ENV" --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check | jq --arg proxy_name "$PROXY_NAME" '.deployments[] | select(.apiProxy == $proxy_name).revision' -r)
apigeecli apis undeploy --name ${PROXY_NAME} --env "$APIGEE_ENV" --rev "$REV" --org "$APIGEE_PROJECT_ID" --token "$TOKEN"

echo "Deleting proxy ${PROXY_NAME} proxy"
apigeecli apis delete --name ${PROXY_NAME} --org "$APIGEE_PROJECT_ID" --token "$TOKEN"

# if [[ "$USE_MOCK" == "true" ]]; then
#   echo "Using mock backend. Undeploying camara-oidc-ciba-mock-backend-v1 proxy"
#   REV=$(apigeecli envs deployments get --env "$APIGEE_ENV" --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check | jq .'deployments[]| select(.apiProxy=="camara-oidc-ciba-mock-backend-v1").revision' -r)
#   apigeecli apis undeploy --name camara-oidc-ciba-mock-backend-v1 --env "$APIGEE_ENV" --rev "$REV" --org "$APIGEE_PROJECT_ID" --token "$TOKEN"

#   echo "Deleting proxy camara-oidc-ciba-mock-backend-v1 proxy"
#   apigeecli apis delete --name camara-oidc-ciba-mock-backend-v1 --org "$APIGEE_PROJECT_ID" --token "$TOKEN"
# fi


echo "Deleting ${TARGET_SERVER_NAME} target server..."
apigeecli targetservers delete --name ${TARGET_SERVER_NAME}  --org "$APIGEE_PROJECT_ID" --env "$APIGEE_ENV" --token "$TOKEN" || { echo "Error: Could not delete target server. Proceeding with the setup..."; }

echo "Undeployment finalized!"