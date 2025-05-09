#!/usr/bin/env bash
# updateContentCommand.sh - Finalize container setup after creation.

# Print each command being executed.
set -x

echo "Invoking $0"

# Set zsh as the default shell when SSHing into this codespace (has no impact
# on VS Code terminals).
sudo chsh -s /bin/zsh ${USER}

# Prepare git auth so that developers can push branches directly from a
# codespaces shell. This step tells git to use auth setup by the GH CLI.
#
# In order for this to actually work, the developer still needs to log into the
# GH CLI from a Codespace terminal using `gh auth login`. That step is
# interactive and opens a browser, so cannot be part of this script.
gh auth setup-git

# Checkout all edx repos using https because at this point the developer has not
# yet authed via the GH CLI. Then, configure each repo to use ssh later.
mkdir -p $DEVSTACK_WORKSPACE
GIT_TERMINAL_PROMPT=0 make dev.clone.https
for repo in $(ls $DEVSTACK_WORKSPACE); do
  pushd ${DEVSTACK_WORKSPACE}/${repo}
  # This is a onvienent setting that we can use to treat http repos as ssh repos.
  git config url.ssh://git@github.com/.insteadOf https://github.com/
  popd
done

# Make sure pyenv & pyenv-virtualenv are installed, updated, and configured
# correctly for zsh shells.
export PYENV_ROOT="/workspaces/.pyenv"
# Idempotently install or update pyenv.
if [[ -d ${PYENV_ROOT}/bin ]]
then (cd ${PYENV_ROOT}; git pull)
else GIT_TERMINAL_PROMPT=0 git clone https://github.com/pyenv/pyenv.git ${PYENV_ROOT}
fi
# Idempotently install or update pyenv-virtualenv.
if [[ -d ${PYENV_ROOT}/plugins/pyenv-virtualenv/bin ]]
then (cd ${PYENV_ROOT}/plugins/pyenv-virtualenv; git pull)
else GIT_TERMINAL_PROMPT=0 git clone https://github.com/pyenv/pyenv-virtualenv.git ${PYENV_ROOT}/plugins/pyenv-virtualenv
fi
# Configure/enable pyenv for zsh.
(
cat <<EOF
export PYENV_ROOT="$PYENV_ROOT"
[[ -d \$PYENV_ROOT/bin ]] && export PATH="\$PYENV_ROOT/bin:\$PATH"
eval "\$(pyenv init - zsh)"
eval "\$(pyenv virtualenv-init - zsh)"
EOF
) > ~/.oh-my-zsh/custom/edx-devstack.zsh
# Enable pyenv for this bash script too.
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"
eval "$(pyenv virtualenv-init - bash)"

# Set up all repos with virtualenvs.
PYTHON_VERSION=3.12
pyenv install --skip-existing $PYTHON_VERSION
for repo in $(ls $DEVSTACK_WORKSPACE); do
  pushd ${DEVSTACK_WORKSPACE}/${repo}
  pyenv virtualenv $PYTHON_VERSION $repo
  pyenv local $repo
  popd
done