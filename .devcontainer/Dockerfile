# TEMPORARY WORKAROUND:
# This removes the legacy Yarn APT repository to unblock Codespaces pre-builds
# failing with:
#   EXPKEYSIG 23E7166788B63E1E Yarn Packaging <yarn@dan.cx>
#
# Root cause: expired/invalid Yarn signing key in the default Microsoft
# devcontainer base image causing `apt-get update` to fail and abort
# devcontainer feature installation.
#
# Tracking:
# - https://2u-internal.atlassian.net/browse/BOMS-394
# - https://2u-internal.atlassian.net/browse/BOMS-402
#
# IMPORTANT: Revert this change after confirming the upstream image no longer
# includes the broken Yarn APT configuration.

FROM mcr.microsoft.com/devcontainers/universal:latest

# Fix: remove legacy Yarn apt repo that can break apt-get update with EXPKEYSIG

RUN rm -f /etc/apt/sources.list.d/yarn.list \
        /etc/apt/sources.list.d/yarn*.list \
    && apt-get update \
    && rm -rf /var/lib/apt/lists/*
