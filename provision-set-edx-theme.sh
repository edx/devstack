#!/usr/bin/env bash

# This script sets up the edX theme in LMS and CMS.

REPO_URL_HTTPS="https://github.com/edx/edx-themes.git"
REPO_URL_SSH="git@github.com:edx/edx-themes.git"
THEME_DIR="/edx/src/edx-themes/edx-platform"
DEVSTACK_FILE="./py_configuration_files/lms.py"

# Clone the edx-themes repository into the src directory
mkdir -p ${DEVSTACK_WORKSPACE}/src
pushd ${DEVSTACK_WORKSPACE}/src
if [ ! -d "edx-themes" ]; then
    # Make a best effort to use SSH, but if that doesn't work then fallback to HTTPS.
    # Also make a best effort to avoid terminal prompting which breaks automation.
    GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new" git clone --depth=1 "$REPO_URL_SSH"
    [[ ! -d "edx-themes" ]] && GIT_TERMINAL_PROMPT=0 git clone --depth=1 "$REPO_URL_HTTPS"
else
    echo "Directory 'edx-themes' already exists. Skipping clone."
fi
popd

# Uncomment relevant lines in the devstack.py file
sed -i '' "s|^# from .common import _make_mako_template_dirs|from .common import _make_mako_template_dirs|" "$DEVSTACK_FILE"
sed -i '' "s|^# ENABLE_COMPREHENSIVE_THEMING = True|ENABLE_COMPREHENSIVE_THEMING = True|" "$DEVSTACK_FILE"
sed -i '' "s|^# COMPREHENSIVE_THEME_DIRS = \[|COMPREHENSIVE_THEME_DIRS = \[|" "$DEVSTACK_FILE"
sed -i '' "s|^#     \"/edx/app/edxapp/edx-platform/themes/\"|    \"/edx/app/edxapp/edx-platform/themes/\",|" "$DEVSTACK_FILE"
sed -i '' "/COMPREHENSIVE_THEME_DIRS = \[/a\\
\"$THEME_DIR\",
" "$DEVSTACK_FILE"
sed -i '' "s|^# \]|]|" "$DEVSTACK_FILE"
sed -i '' "s|^# TEMPLATES\[1\]\[\"DIRS\"\] = Derived(_make_mako_template_dirs)|TEMPLATES[1][\"DIRS\"] = Derived(_make_mako_template_dirs)|" "$DEVSTACK_FILE"
sed -i '' "s|^# derive_settings(__name__)|derive_settings(__name__)|" "$DEVSTACK_FILE"


# Add the theme directory to COMPREHENSIVE_THEME_DIRS if not already present
if ! grep -qF "$THEME_DIR" "$DEVSTACK_FILE"; then
  sed -i '' "/COMPREHENSIVE_THEME_DIRS = \[/a\\
    \"$THEME_DIR\",
  " "$DEVSTACK_FILE"
fi

# Set the theme site-wide
SERVICE_NAME="mysql80"
DATABASE="edxapp"
THEME_NAME="edx.org-next"
SITE_ID=1

docker compose exec -T "$SERVICE_NAME" mysql -e "
USE $DATABASE;
INSERT INTO theming_sitetheme (theme_dir_name, site_id) VALUES ('$THEME_NAME', $SITE_ID);
"
