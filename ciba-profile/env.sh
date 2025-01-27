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

export APIGEE_PROJECT_ID="APIGEE_PROJECT_ID_TO_SET"
export APIGEE_HOST="APIGEE_HOST_TO_SET" # such as https://api.mydomain.com - include http/https in the variable
export APIGEE_ENV="APIGEE_ENV_TO_SET" # such as dev, prod
export CLIENT_JKWS_URI="CLIENT_JWKS_URI" # URI for the JWKS used for signing client assertions, such as https://token.dev/jwks/keys.json
export TARGET_SERVER_STUFF # TODO