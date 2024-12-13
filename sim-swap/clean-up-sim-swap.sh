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

echo "Undeploying camara-sim-swap-v1 proxy"
REV=$(apigeecli envs deployments get --env "$APIGEE_ENV" --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check | jq .'deployments[]| select(.apiProxy=="camara-sim-swap-v1").revision' -r)
apigeecli apis undeploy --name camara-sim-swap-v1 --env "$APIGEE_ENV" --rev "$REV" --org "$APIGEE_PROJECT_ID" --token "$TOKEN"

echo "Deleting proxy camara-sim-swap-v1 proxy"
apigeecli apis delete --name camara-sim-swap-v1 --org "$APIGEE_PROJECT_ID" --token "$TOKEN"

echo "Undeploying mock-sim-swap-v1 proxy"
REV=$(apigeecli envs deployments get --env "$APIGEE_ENV" --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check | jq .'deployments[]| select(.apiProxy=="mock-sim-swap-v1").revision' -r)
apigeecli apis undeploy --name mock-sim-swap-v1 --env "$APIGEE_ENV" --rev "$REV" --org "$APIGEE_PROJECT_ID" --token "$TOKEN"

echo "Deleting proxy mock-sim-swap-v1 proxy"
apigeecli apis delete --name mock-sim-swap-v1 --org "$APIGEE_PROJECT_ID" --token "$TOKEN"