#!/usr/bin/env bash
# postCreateCommand.sh - Finalize container setup after creation.
#
# This script will contribute to the time it takes to launch a new codespace.

# Print each command being executed.
set -x

echo "Invoking $0"

# Overwrite the default welcome message.
# This is displayed the first time you open a newly created Codespace.
VSCODE_DEVCONTAINERS_CONFIG=/usr/local/etc/vscode-dev-containers
if [[ -d "$VSCODE_DEVCONTAINERS_CONFIG" ]]; then
  sudo cp .devcontainer/welcome.txt ${VSCODE_DEVCONTAINERS_CONFIG}/first-run-notice.txt
fi

# Prepare git auth so that developers can push branches directly from a
# codespaces shell. This step tells git to use auth setup by the GH CLI.
#
# In order for this to actually work, the developer still needs to log into the
# GH CLI from a Codespace terminal using `gh auth login`. That step is
# interactive and opens a browser, so cannot be part of this script.
gh auth setup-git
