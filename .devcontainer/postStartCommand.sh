#!/usr/bin/env bash
# postStartCommand.sh - Run each time the container is successfully started.

# Print each command being executed.
set -x

echo "Invoking $0"

if [[ -d ~/.ssh ]]; then
  # Backup user-generated ~/.ssh folder if present.
  rsync -avh ~/.ssh/ /workspaces/.ssh-backup/
elif [[ -d /workspaces/.ssh-backup ]]; then
  # Recover user-generated ~/.ssh folder if absent.
  rsync -avh /workspaces/.ssh-backup/ ~/.ssh/
fi
# No action is taken if neither ~/.ssh nor /workspaces/.ssh-backup exists.