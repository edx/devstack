#!/usr/bin/env bash
set -e

echo "Fixing expired Yarn GPG key..."

# Remove old Yarn repository configuration if it exists
rm -f /etc/apt/sources.list.d/yarn.list /etc/apt/sources.list.d/yarn.list.save 2>/dev/null || true

# Remove old GPG key if it exists (using deprecated apt-key method)
apt-key del 23E7166788B63E1E 2>/dev/null || true

# Add Yarn repository with updated GPG key using modern method
curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarn-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/yarn-keyring.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list

echo "Yarn GPG key fixed successfully."
