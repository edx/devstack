#!/usr/bin/env bash
#
# Migrate all enterprise repo clones from openedx to edx github org.
#
#
set -eu -o pipefail

REPOS=(
  enterprise-access
  enterprise-subsidy
  enterprise-catalog
  license-manager

  # TODO frontend apps:
  # frontend-app-admin-portal
  # frontend-app-learner-portal-enterprise
  # frontend-app-enterprise-checkout
  # frontend-app-enterprise-public-catalog

  # TODO libraries:
  # edx-enterprise
  # edx-enterprise-data
  # frontend-enterprise
  # enterprise-integrated-channels
  # edx-enterprise-subsidy-client
)

for repo in "${REPOS[@]}"; do
  echo "Updating $repo ..."
  if [ ! -d "$DEVSTACK_WORKSPACE/$repo" ]; then
    echo "Skipping $repo (not found)"
    continue
  fi
  pushd "$DEVSTACK_WORKSPACE/$repo" >/dev/null
  OLD_ORIGIN=$(git remote get-url origin)
  git remote set-url origin $(git remote get-url origin | sed 's/openedx/edx/')
  NEW_ORIGIN=$(git remote get-url origin)
  echo "Old origin: ${OLD_ORIGIN}"
  echo "New origin: ${NEW_ORIGIN}"
  popd >/dev/null
  echo
done

echo "Migration complete."
