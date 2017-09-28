#!/bin/bash

# on test_zhian
# deploy cloudify and clearwater
source ./bootstrap_cloudify_manager.sh
source ./deploy_clearwater_via_cloudify_CLI.sh

set -e
bootstrap_cloudify_manager
deploy_clearwater
