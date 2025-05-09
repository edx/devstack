#!/usr/bin/env bash
# postStartCommand.sh - Run each time the codespace is successfully started.
#
# This script contributes the time it takes to start the codespace _every day_.

# Print each command being executed.
set -x

echo "Invoking $0"

# `gh auth login` generates SSH keys under the home directory, but that part of
# the filesystem is ephemeral. Make a decent effort to store the keys in a
# persistent mount, and recover the keys if necessary.
if ls -d ~/.ssh/id_*; then
  # Backup user-generated ~/.ssh folder if keys are present.
  rsync -avh ~/.ssh/ /workspaces/.ssh-backup/
elif [[ -d /workspaces/.ssh-backup ]]; then
  # Recover user-generated ~/.ssh folder if absent and a backup exists.
  rsync -avh /workspaces/.ssh-backup/ ~/.ssh/
fi
# No action is taken if neither ~/.ssh nor /workspaces/.ssh-backup exists.
