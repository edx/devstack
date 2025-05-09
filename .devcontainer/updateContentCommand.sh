#!/usr/bin/env bash
# updateContentCommand.sh - Finalize container setup after creation.
#
# The result of these commands are cached in pre-built codespaces and will
# not contribute to any developer delay.  When new codespaces are pre-built
# behind the scenes, this script runs, so it'll probably run weekly.

# Print each command being executed.
set -x

echo "Invoking $0"

# Set zsh as the default shell when SSHing into this codespace (has no impact
# on VS Code terminals).
sudo chsh -s /bin/zsh ${USER}

# Add github.com to ssh known hosts to avoid crashing the build with a prompt.
mkdir -p ~/.ssh
ssh-keyscan -H github.com >> ~/.ssh/known_hosts

# Checkout all edx repos using https because at this point the developer has
# not yet authed via the GH CLI. Later we'll, configure each repo to use ssh.
mkdir -p "$DEVSTACK_WORKSPACE"
mkdir -p "$DEVSTACK_WORKSPACE/src"
SHALLOW_CLONE=1 make dev.clone.https

# Provision the core app databases.
make dev.provision
# Provision the enterprise app databases.
make dev.provision.license-manager+enterprise-catalog+enterprise-access+enterprise-subsidy

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

# Install a decent long-term python version.
PYTHON_VERSION=3.12
pyenv install --skip-existing $PYTHON_VERSION

# Find all repos and loop over them:
repo_dirs=( $(find $DEVSTACK_WORKSPACE -mindepth 1 -maxdepth 3 -type d -name .git) )
repo_dirs=( ${repo_dirs[@]%/.git} )
for repo_dir in ${repo_dirs[@]}; do
  pushd $repo_dir

  # Produce a human-readable virtualenv name.
  virtualenv_name="${repo_dir#$DEVSTACK_WORKSPACE/}"
  virtualenv_name="${virtualenv_name//\//_}"

  # Set up all repos with virtualenvs.
  echo pyenv virtualenv $PYTHON_VERSION $repo_name
  echo pyenv local $repo_name

  # Configure all repo clones to use SSH instead of HTTPS.
  echo sed -i 's/https:\/\/github.com\//git@github.com:/g' .git/config

  popd
done
