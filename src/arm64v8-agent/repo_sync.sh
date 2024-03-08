#!/bin/bash

# Fail script on any error
set -e

# Ensure GITHUB_TOKEN and REPO_URL are provided
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: GITHUB_TOKEN environment variable is not set."
  exit 1
fi

if [ -z "$REPO_URL" ]; then
  echo "Error: REPO_URL environment variable is not set."
  exit 1
fi

# Static repository path
REPO_PATH="/repo"

# Optional: Specify branch if desired, default to main
BRANCH="${BRANCH:-main}"

# Clone or fetch repo depending on its presence
if [ ! -d "$REPO_PATH/.git" ]; then
  echo "Cloning repository for the first time..."
  git clone https://$GITHUB_TOKEN:x-oauth-basic@${REPO_URL#https://} "$REPO_PATH"
fi

# Get the latest local SHA of the branch
local_sha=$(git -C "$REPO_PATH" rev-parse "$BRANCH")

# Get the latest remote SHA of the branch
remote_sha=$(git -C "$REPO_PATH" rev-parse "origin/$BRANCH")

# Compare the SHAs
if [ "$local_sha" != "$remote_sha" ]; then
  echo "New changes detected in the remote repository."
  # Here you can add commands to handle the new changes, like merging them or triggering a deployment script
else
  echo "No new changes detected."
fi
