#!/bin/bash

# Copyright 2024 Google LLC
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

echo "Installing apigeecli"
curl -s https://raw.githubusercontent.com/apigee/apigeecli/main/downloadLatest.sh | bash
export PATH=$PATH:$HOME/.apigeecli/bin

TOKEN=$(gcloud auth print-access-token)
gcloud config set project "$APIGEE_PROJECT_ID"

echo "Deploying Apigee artifacts..."

echo "Importing and Deploying Apigee camara-sim-swap-v1 proxy..."
REV=$(apigeecli apis create bundle -f ./camara-sim-swap/apiproxy -n camara-sim-swap-v1 --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check | jq ."revision" -r)
apigeecli apis deploy --wait --name camara-sim-swap-v1 --ovr --rev "$REV" --org "$APIGEE_PROJECT_ID" --env "$APIGEE_ENV" --token "$TOKEN"

echo "Importing and Deploying Apigee mock-sim-swap-v1 proxy..."
REV=$(apigeecli apis create bundle -f ./mock-sim-swap/apiproxy -n mock-sim-swap-v1 --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check | jq ."revision" -r)
apigeecli apis deploy --wait --name mock-sim-swap-v1 --ovr --rev "$REV" --org "$APIGEE_PROJECT_ID" --env "$APIGEE_ENV" --token "$TOKEN"

echo " "
echo "All the Apigee artifacts are successfully deployed!"
# echo "Your API_ENDPOINT is: https://$APIGEE_HOST/v1/samples/llm-logging"