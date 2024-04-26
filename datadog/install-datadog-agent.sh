#!/bin/bash
# Set up Datadog Agent. This should be run with appropriate environment variables set.
#
# See https://2u-internal.atlassian.net/wiki/spaces/ENG/pages/1173618788/Running+Datadog+in+devstack

set -eu -o pipefail

which curl || {
    apt-get update
    apt-get install -y curl
}

curl -L "https://s3.amazonaws.com/dd-agent/scripts/install_script_agent7.sh" | bash
