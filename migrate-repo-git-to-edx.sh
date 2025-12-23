#!/usr/bin/env bash
#
# Migrate all enterprise repo clones from openedx to edx github org.
#
# If an "origin" remote is used, re-write its URL to utilize the edx repo.  If the main
# branch tracks the "openedx" remote, re-write it to track the "edx" remote.
#

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

# If a specific repo has been requested, limit execution to that one only.
if [[ $# -eq 1 ]] ; then
  REPOS=($1)
fi

for repo in "${REPOS[@]}"; do
  echo "Updating $repo ..."
  if [ ! -d "$DEVSTACK_WORKSPACE/$repo" ]; then
    echo "Skipping $repo: not found"
    continue
  fi
  pushd "$DEVSTACK_WORKSPACE/$repo" >/dev/null
  origin_remote_url=$(git remote get-url origin 2>/dev/null)
  if [ -n "${origin_remote_url}" ]; then
    # An "origin" remote has been found! Simply re-write that origin to point to "edx".
    # Use `sed` to avoid complicated conditional logic around SSH vs. HTTPS.
    git remote set-url origin "$(git remote get-url origin | sed 's/openedx/edx/')"
    new_origin_remote_url=$(git remote get-url origin)
    echo "Old origin: ${origin_remote_url}"
    echo "New origin: ${new_origin_remote_url}"
  else
    # "origin" remote does not exist, so assume the main branch has been configured to
    # point to an "openedx" remote, and an "edx" remote exists.
    edx_remote_url=$(git remote get-url edx 2>/dev/null)
    if [ -z "${edx_remote_url}" ]; then
      echo "Skipping $repo: Could not find \"edx\" remote."
      popd >/dev/null
      continue
    fi
    main_branch_id=$(git rev-parse --verify --quiet main)
    if [ -n "${main_branch_id}" ]; then
      branch_to_update=main
    else
      branch_to_update=master
    fi
    main_branch_remote=$(git config branch.${branch_to_update}.remote)
    if [ "${main_branch_remote}" != "edx" ]; then
      git config branch.${branch_to_update}.remote edx
      new_main_branch_remote=$(git config branch.${branch_to_update}.remote)
      echo "Old tracking remote: ${main_branch_remote}"
      echo "New tracking remote: ${new_main_branch_remote}"
    else
      echo "Skipping $repo: ${branch_to_update} branch was already configured to track edx remote."
      popd >/dev/null
      continue
    fi
  fi
  popd >/dev/null
  echo
done

echo "Migration complete."
