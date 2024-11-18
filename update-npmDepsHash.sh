#!/bin/bash

# Note: This script may hang indefinitely if dependencies didn't change, as 'nix run' will start the server and run indefinitely.
# DO NOT UPDATE package.nix while this script is running.

# Path to your Nix file
NIX_FILE="nix/package.nix"

# Run the nix command and capture both stdout and stderr
echo "Running 'nix run' to check for hash mismatch..."
OUTPUT=$(nix run --extra-experimental-features nix-command --extra-experimental-features flakes --offline 2>&1)

# Check if the output contains the 'npmDepsHash is out of date' error message
if echo "$OUTPUT" | grep -E 'ERROR: npmDepsHash is out of date' > /dev/null; then
  echo "npmDepsHash is out of date. Update npmDepsHash in process..."
  
  # Stage 1 to Stage 2: Update the Nix file to use lib.fakeHash
  sed -i '' -E 's|{ pkgs }|{ pkgs, lib ? pkgs.lib }|' "$NIX_FILE"
  sed -i '' -E 's|npmDepsHash = ".*";|npmDepsHash = lib.fakeHash;|' "$NIX_FILE"
  
  # Re-run nix run to generate the correct hash
  OUTPUT=$(nix run --extra-experimental-features nix-command --extra-experimental-features flakes --offline 2>&1)

  # Extract the correct sha256 hash from the output using grep and awk
  NEW_HASH=$(echo "$OUTPUT" | grep -E 'got:    sha256-' | awk '{print $2}')

  # Check if the hash was extracted successfully
  if [ -z "$NEW_HASH" ]; then
    echo "Error: Could not extract the sha256 hash from the output."
    echo "Full output from nix run:"
    echo "$OUTPUT"
    exit 1
  fi

  # Stage 2 to Stage 3: Replace lib.fakeHash with the actual sha256 hash
  sed -i '' -E 's|{ pkgs, lib ? pkgs.lib }|{ pkgs }|' "$NIX_FILE"
  sed -i '' "s|npmDepsHash = lib.fakeHash;|npmDepsHash = \"$NEW_HASH\";|" "$NIX_FILE"

  echo "Updated '$NIX_FILE' with the new npmDepsHash: $NEW_HASH"

else
  echo "No hash mismatch found. No changes needed."
  exit 0
fi
