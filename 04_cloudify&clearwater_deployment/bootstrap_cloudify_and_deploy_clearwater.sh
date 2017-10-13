#!/bin/bash

# on test_zhian
# you had better copy bootstrap_cloudify_manager.sh, deploy_clearwater_via_cloudify_CLI.sh
# and bootstrap_cloudify_and_deploy_clearwater.sh to your home directory for a clean pythonenv
# environment

# deploy cloudify and clearwater
source ./bootstrap_cloudify_manager.sh
source ./deploy_clearwater_via_cloudify_CLI.sh

set -e

bootstrap_cloudify_manager
deploy_clearwater
