#!/usr/bin/env bash

set -e
set -o pipefail

# Script for Git repos housing edX services. These repos are mounted as
# data volumes into their corresponding Docker containers to facilitate development.
# Repos are cloned to/removed from the directory above the one housing this file.

if [ -z "$DEVSTACK_WORKSPACE" ]; then
    echo "need to set workspace dir"
    exit 1
elif [ -d "$DEVSTACK_WORKSPACE" ]; then
    cd "$DEVSTACK_WORKSPACE"
else
    echo "Workspace directory $DEVSTACK_WORKSPACE doesn't exist"
    exit 1
fi

# When you add new services should add them to both repos and ssh_repos
# (or non_release_repos and non_release_ssh_repos if they are not part
# of Open edX releases).
repos=(
    "https://github.com/openedx/course-discovery.git"
    "https://github.com/openedx/credentials.git"
    "https://github.com/openedx/cs_comments_service.git"
    "https://github.com/edx/ecommerce.git"
    "https://github.com/openedx/edx-notes-api.git"
    "https://github.com/edx/edx-platform.git"
    "https://github.com/openedx/xqueue.git"
    "https://github.com/edx/edx-analytics-dashboard.git"
    "https://github.com/edx/frontend-app-gradebook.git"
    "https://github.com/edx/frontend-app-learner-dashboard.git"
    "https://github.com/edx/frontend-app-learner-record.git"
    "https://github.com/edx/frontend-app-payment.git"
    "https://github.com/edx/frontend-app-publisher.git"
    "https://github.com/edx/edx-analytics-data-api.git"
    "https://github.com/edx/enterprise-catalog.git"
    "https://github.com/edx/portal-designer.git"
    "https://github.com/edx/license-manager.git"
    "https://github.com/openedx/codejail-service.git"
    "https://github.com/edx/enterprise-access.git"
)

non_release_repos=(
    "https://github.com/openedx/frontend-app-authn.git"
    "https://github.com/openedx/frontend-app-course-authoring.git"
    "https://github.com/edx/frontend-app-learning.git"
    "https://github.com/edx/registrar.git"
    "https://github.com/edx/frontend-app-program-console.git"
    "https://github.com/openedx/frontend-app-account.git"
    "https://github.com/edx/frontend-app-profile.git"
    "https://github.com/edx/frontend-app-ora-grading.git"
    "https://github.com/edx/enterprise-subsidy.git"
    "https://github.com/edx/frontend-app-admin-portal.git"
    "https://github.com/edx/frontend-app-learner-portal-enterprise.git"
    "https://github.com/edx/frontend-app-enterprise-checkout.git"
    "https://github.com/edx/edx-exams.git"
    "https://github.com/edx/frontend-app-skills.git"
    "https://github.com/edx/frontend-app-ora.git"
    "https://github.com/edx/frontend-app-exams-dashboard.git"
    "https://github.com/edx/frontend-app-learner-portal-programs.git"
    "https://github.com/edx/frontend-app-communications.git"
    "https://github.com/edx/frontend-app-discussions.git"
    "https://github.com/edx/frontend-app-enterprise-public-catalog.git"
    "https://github.com/edx/frontend-app-support-tools.git"
    "https://github.com/edx/frontend-app-authoring.git"
    "https://github.com/edx/frontend-app-instruct.git"
    "https://github.com/edx/frontend-app-catalog.git"
    "https://github.com/edx/openedx-translations.git"
)

ssh_repos=(
    "git@github.com:openedx/course-discovery.git"
    "git@github.com:openedx/credentials.git"
    "git@github.com:openedx/cs_comments_service.git"
    "git@github.com:edx/ecommerce.git"
    "git@github.com:openedx/edx-notes-api.git"
    "git@github.com:edx/enterprise-catalog.git"
    "git@github.com:edx/edx-platform.git"
    "git@github.com:openedx/xqueue.git"
    "git@github.com:edx/edx-analytics-dashboard.git"
    "git@github.com:edx/frontend-app-gradebook.git"
    "git@github.com:edx/frontend-app-learner-dashboard.git"
    "git@github.com:edx/frontend-app-learner-record.git"
    "git@github.com:edx/frontend-app-payment.git"
    "git@github.com:edx/frontend-app-publisher.git"
    "git@github.com:edx/edx-analytics-data-api.git"
    "git@github.com:edx/portal-designer.git"
    "git@github.com:edx/license-manager.git"
    "git@github.com:openedx/codejail-service.git"
    "git@github.com:edx/enterprise-access.git"
)

non_release_ssh_repos=(
    "git@github.com:openedx/frontend-app-authn.git"
    "git@github.com:openedx/frontend-app-course-authoring.git"
    "git@github.com:edx/frontend-app-learning.git"
    "git@github.com:edx/registrar.git"
    "git@github.com:edx/frontend-app-program-console.git"
    "git@github.com:openedx/frontend-app-account.git"
    "git@github.com:edx/frontend-app-profile.git"
    "git@github.com:edx/frontend-app-ora-grading.git"
    "git@github.com:edx/enterprise-subsidy.git"
    "git@github.com:edx/frontend-app-admin-portal.git"
    "git@github.com:edx/frontend-app-learner-portal-enterprise.git"
    "git@github.com:edx/frontend-app-enterprise-checkout.git"
    "git@github.com:edx/edx-exams.git"
    "git@github.com:edx/frontend-app-skills.git"
    "git@github.com:edx/frontend-app-ora.git"
    "git@github.com:edx/frontend-app-exams-dashboard.git"
    "git@github.com:edx/frontend-app-learner-portal-programs.git"
    "git@github.com:edx/frontend-app-communications.git"
    "git@github.com:edx/frontend-app-discussions.git"
    "git@github.com:edx/frontend-app-enterprise-public-catalog.git"
    "git@github.com:edx/frontend-app-support-tools.git"
    "git@github.com:edx/frontend-app-authoring.git"
    "git@github.com:edx/frontend-app-instruct.git"
    "git@github.com:edx/frontend-app-catalog.git"
    "git@github.com:edx/openedx-translations.git"
)

if [ -n "${OPENEDX_RELEASE}" ]; then
    OPENEDX_GIT_BRANCH=open-release/${OPENEDX_RELEASE}
else
    repos+=("${non_release_repos[@]}")
    ssh_repos+=("${non_release_ssh_repos[@]}")
fi

name_pattern=".*/(.*).git$"

_checkout ()
{
    repos_to_checkout=("$@")

    for repo in "${repos_to_checkout[@]}"
    do
        # Use Bash's regex match operator to capture the name of the repo.
        # Results of the match are saved to an array called $BASH_REMATCH.
        if [[ ! $repo =~ $name_pattern ]]; then
            echo "Cannot perform checkout on repo; URL did not match expected pattern: $repo"
            exit 1
        fi
        name="${BASH_REMATCH[1]}"

        # If a directory exists and it is nonempty, assume the repo has been cloned.
        if [ -d "$name" ] && [ -n "$(ls -A "$name" 2>/dev/null)" ]; then
            cd "$name"
            _checkout_and_update_branch "${repo}"
            cd ..
        fi
    done
}

checkout ()
{
    _checkout "${repos[@]}"
}

_clone ()
{

    repos_to_clone=("$@")
    for repo in "${repos_to_clone[@]}"
    do
        # Use Bash's regex match operator to capture the name of the repo.
        # Results of the match are saved to an array called $BASH_REMATCH.
        if [[ ! $repo =~ $name_pattern ]]; then
            echo "Cannot clone repo; URL did not match expected pattern: $repo"
            exit 1
        fi
        name="${BASH_REMATCH[1]}"

        # If a directory exists and it is nonempty, assume the repo has been checked out
        # and only make sure it's on the required branch
        if [ -d "$name" ] && [ -n "$(ls -A "$name" 2>/dev/null)" ]; then
            if [ ! -d "$name/.git" ]; then
                printf "ERROR: [%s] exists but is not a git repo.\n" "$name"
                exit 1
            fi
            printf "The [%s] repo is already checked out. Checking for updates.\n" "$name"
            cd "${DEVSTACK_WORKSPACE}/${name}"
            _checkout_and_update_branch "${repo}"
            cd ..
        else
            if [ -n "${OPENEDX_GIT_BRANCH:-}" ]; then
                CLONE_BRANCH="-b ${OPENEDX_GIT_BRANCH}"
            elif [[ "${repo}" == *"edx/ecommerce"* ]]; then
                CLONE_BRANCH="-b 2u/main"
            else
                CLONE_BRANCH=""
            fi
            if [ "${SHALLOW_CLONE}" == "1" ]; then
                git clone ${CLONE_BRANCH} -c core.symlinks=true --depth=1 "${repo}"
                # Set up developers for success by tracking all remote branches, otherwise remote branches
                # cannot be checked-out. This only edits a text file, so it adds negligible time.
                pushd "${name}"
                git remote set-branches origin '*'
                popd
            else
                git clone ${CLONE_BRANCH} -c core.symlinks=true "${repo}"
            fi
        fi
    done
    cd - &> /dev/null
}

_checkout_and_update_branch ()
{
    local current_repo=$1
    GIT_SYMBOLIC_REF="$(git symbolic-ref HEAD 2>/dev/null)"
    BRANCH_NAME=${GIT_SYMBOLIC_REF##refs/heads/}
    if [ -n "${OPENEDX_GIT_BRANCH}" ]; then
        CHECKOUT_BRANCH=${OPENEDX_GIT_BRANCH}
    elif [[ "${current_repo}" == *"edx/ecommerce"* ]]; then
        CHECKOUT_BRANCH="2u/main"
    else
        CHECKOUT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
    fi
    echo "Checking out branch ${CHECKOUT_BRANCH}"
    if [ "${BRANCH_NAME}" == "${CHECKOUT_BRANCH}" ]; then
        git pull origin ${CHECKOUT_BRANCH}
    else
        git fetch origin ${CHECKOUT_BRANCH}:${CHECKOUT_BRANCH}
        git checkout ${CHECKOUT_BRANCH}
    fi
    find . -name '*.pyc' -not -path './.git/*' -delete
}

clone ()
{
    _clone "${repos[@]}"
}

clone_ssh ()
{
    _clone "${ssh_repos[@]}"
}

checkout_and_pull_default_branch ()
{
    local name=$1
    local dir_path=${2:-$1}
    if [ -d "$name" ]; then
        DEFAULT_BRANCH=$(cd ${dir_path}; git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
        # Try to switch branch and pull, but fail if there are uncommitted changes.
        if (cd "$dir_path"; git checkout -q ${DEFAULT_BRANCH} && git pull -q --ff-only);
        then
            # Echo untracked files to simplify debugging and make it easier to see that resetting does not remove everything
            untracked_files="$(cd ${dir_path} && git ls-files --others --exclude-standard)"
            if [[ $untracked_files ]];
            then
                echo "The following untracked files are in ${name} repository:"
                echo "$untracked_files"
            fi
        else
            echo >&2 "Failed to reset $name repo. Exiting."
            echo >&2 "Please go to the repo and clean up any issues that are keeping 'git checkout $DEFAULT_BRANCH' and 'git pull' from working."
            exit 1
        fi
    else
        printf "The [%s] repo is not cloned. Skipping.\n" "$name"
    fi
}

reset ()
{
    read -p "This will switch to the default branch and pull changes in your local git checkouts. Would you like to proceed? [y/n] " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelling."
        exit 1
    fi

    for repo in ${repos[*]}
    do
        if [[ ! $repo =~ $name_pattern ]]; then
            echo "Cannot reset repo; URL did not match expected pattern: $repo"
            exit 1
        fi
        name="${BASH_REMATCH[1]}"
        checkout_and_pull_default_branch "$name"
    done

    echo "Updating edx-themes repo..."
    themes_directory="src/edx-themes"
    if [ -d "$themes_directory" ]; then
        checkout_and_pull_default_branch "edx-themes" "$themes_directory"
    fi
}

status ()
{
    currDir=$(pwd)
    for repo in ${repos[*]}
    do
        if [[ ! $repo =~ $name_pattern ]]; then
            echo "Cannot check repo status; URL did not match expected pattern: $repo"
            exit 1
        fi
        name="${BASH_REMATCH[1]}"

        if [ -d "$name" ]; then
            printf "\nGit status for [%s]:\n" "$name"
            cd "$name";git status;cd "$currDir"
        else
            printf "The [%s] repo is not cloned. Skipping.\n" "$name"
        fi
    done
    cd - &> /dev/null
}

# Define repositories that exist in both edx and openedx organizations
# These are the ones that need remote setup for forked repositories
FORKED_REPOS=(
    "course-discovery"
    "credentials"
    "cs_comments_service"
    "ecommerce"
    "edx-notes-api"
    "edx-platform"
    "xqueue"
    "edx-analytics-dashboard"
    "frontend-app-gradebook"
    "frontend-app-learner-dashboard"
    "frontend-app-learner-record"
    "frontend-app-skills"
    "frontend-app-learning"
    "frontend-app-ora"
    "frontend-app-ora-grading"
    "frontend-app-exams-dashboard"
    "frontend-app-learner-portal-programs"
    "frontend-app-program-console"
    "frontend-app-communications"
    "frontend-app-discussions"
    "frontend-app-profile"
    "frontend-app-enterprise-public-catalog"
    "frontend-app-publisher"
    "frontend-app-support-tools"
    "frontend-app-admin-portal"
    "frontend-app-learner-portal-enterprise"
    "frontend-app-enterprise-checkout"
    "frontend-app-authoring"
    "frontend-app-instruct"
    "frontend-app-catalog"
    "openedx-translations"
    "frontend-app-payment"
    "edx-analytics-data-api"
    "portal-designer"
    "codejail-service"
    "frontend-app-authn"
    "frontend-app-course-authoring"
    "registrar"
    "frontend-app-account"
    "edx-exams"
)

setup_forked_repo_remotes ()
{
    local repo_name=$1
    local edx_remote_exists
    local openedx_remote_exists
    local origin_exists
    local existing_url=""
    local existing_org=""
    local other_org
    local other_remote_exists
    local other_url

    # Check if we're in a git repository
    if [ ! -d ".git" ]; then
        echo "ERROR: $repo_name is not a git repository"
        return 1
    fi

    # Check if both remotes already exist (idempotency check)
    edx_remote_exists=$(git remote | grep "^edx$" || true)
    openedx_remote_exists=$(git remote | grep "^openedx$" || true)
    origin_exists=$(git remote | grep "^origin$" || true)

    if [ -n "$edx_remote_exists" ] && [ -n "$openedx_remote_exists" ] && [ -z "$origin_exists" ]; then
        echo "Both edx and openedx remotes already exist in $repo_name. No changes needed."
        return 0
    fi

    echo "Setting up remotes for forked repository: $repo_name"

    # First, try to find an existing remote and its URL
    if [ -n "$origin_exists" ]; then
        # We have an 'origin' remote - determine its organization
        existing_url=$(git remote get-url origin 2>/dev/null || true)

        if [[ $existing_url =~ github\.com[:/]edx/ ]]; then
            existing_org="edx"
        elif [[ $existing_url =~ github\.com[:/]openedx/ ]]; then
            existing_org="openedx"
        else
            echo "ERROR: Unexpected origin URL in $repo_name: $existing_url"
            echo "Expected URL to be from either edx or openedx organization"
            return 1
        fi

        # Rename origin to the correct organization name if not already done
        if ! git remote | grep -q "^${existing_org}$"; then
            echo "Renaming origin to '$existing_org' in $repo_name"
            if ! git remote rename origin "$existing_org"; then
                echo "ERROR: Failed to rename origin to $existing_org in $repo_name"
                return 1
            fi
        else
            echo "Remote '$existing_org' already exists, removing origin"
            git remote remove origin 2>/dev/null || true
        fi
    elif [ -n "$edx_remote_exists" ]; then
        # No origin, but we have an 'edx' remote - use it as reference
        existing_url=$(git remote get-url edx)
        existing_org="edx"
    elif [ -n "$openedx_remote_exists" ]; then
        # No origin or edx, but we have an 'openedx' remote - use it as reference
        existing_url=$(git remote get-url openedx)
        existing_org="openedx"
    else
        echo "ERROR: No remotes found in $repo_name"
        return 1
    fi

    # Determine the other organization and add its remote if missing
    if [ "$existing_org" = "edx" ]; then
        other_org="openedx"
    else
        other_org="edx"
    fi

    # Check if the other remote exists
    other_remote_exists=$(git remote | grep "^${other_org}$" || true)

    if [ -z "$other_remote_exists" ]; then
        # Construct the URL for the other organization
        if [[ $existing_url =~ ^git@ ]]; then
            # SSH URL format
            other_url="git@github.com:${other_org}/${repo_name}.git"
        else
            # HTTPS URL format
            other_url="https://github.com/${other_org}/${repo_name}.git"
        fi

        echo "Adding $other_org remote: $other_url"
        if ! git remote add "$other_org" "$other_url"; then
            echo "ERROR: Failed to add $other_org remote in $repo_name"
            return 1
        fi
    else
        echo "Remote '$other_org' already exists in $repo_name"
    fi

    echo "Successfully configured remotes for $repo_name"
    return 0
}

setup_all_forked_repo_remotes ()
{
    local successful_repos=()
    local failed_repos=()
    local skipped_repos=()
    local repo
    local name
    local is_forked
    local forked_repo

    echo "Setting up remotes for all forked repositories..."
    echo "========================================"

    for repo in "${repos[@]}" "${non_release_repos[@]}"
    do
        # Extract repo name from URL
        if [[ ! $repo =~ $name_pattern ]]; then
            echo "Cannot setup remotes for repo; URL did not match expected pattern: $repo"
            continue
        fi
        name="${BASH_REMATCH[1]}"

        # Check if directory exists
        if [ ! -d "$name" ]; then
            echo "Repository $name is not cloned. Skipping."
            skipped_repos+=("$name")
            continue
        fi

        # Check if this repo is configured as a forked repo
        is_forked=false
        for forked_repo in "${FORKED_REPOS[@]}"; do
            if [[ "$forked_repo" == "$name" ]]; then
                is_forked=true
                break
            fi
        done

        if [[ "$is_forked" == false ]]; then
            echo "Repository $name is not configured as a forked repo. Skipping."
            skipped_repos+=("$name")
            continue
        fi

        # Change to repo directory and setup remotes
        cd "$name"
        if setup_forked_repo_remotes "$name"; then
            successful_repos+=("$name")
        else
            failed_repos+=("$name")
        fi
        cd "$DEVSTACK_WORKSPACE"
        echo ""
    done

    # Print summary report
    echo "========================================"
    echo "Remote Setup Summary:"
    echo "========================================"

    if [ ${#successful_repos[@]} -gt 0 ]; then
        echo "✓ Successfully configured remotes for ${#successful_repos[@]} repositories:"
        printf "  - %s\n" "${successful_repos[@]}"
        echo ""
    fi

    if [ ${#failed_repos[@]} -gt 0 ]; then
        echo "✗ Failed to configure remotes for ${#failed_repos[@]} repositories:"
        printf "  - %s\n" "${failed_repos[@]}"
        echo ""
    fi

    if [ ${#skipped_repos[@]} -gt 0 ]; then
        echo "◦ Skipped ${#skipped_repos[@]} repositories (not cloned or not forked):"
        printf "  - %s\n" "${skipped_repos[@]}"
        echo ""
    fi

    echo "Total repositories processed: $((${#successful_repos[@]} + ${#failed_repos[@]} + ${#skipped_repos[@]}))"

    if [ ${#failed_repos[@]} -gt 0 ]; then
        return 1
    else
        return 0
    fi
}

if [ "$1" == "checkout" ]; then
    checkout
elif [ "$1" == "clone" ]; then
    clone
elif [ "$1" == "clone_ssh" ]; then
    clone_ssh
elif [ "$1" == "reset" ]; then
    reset
elif [ "$1" == "status" ]; then
    status
elif [ "$1" == "setup-remotes" ]; then
    setup_all_forked_repo_remotes
fi
