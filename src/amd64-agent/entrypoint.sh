#!/bin/bash

# Path to the repo checker script
REPO_CHECKER_SCRIPT="/usr/src/app/repo_sync.sh"

# Make sure the repo checker script is executable
chmod +x "$REPO_CHECKER_SCRIPT"

# Infinite loop to run the repo checker script every 5 minutes
while true; do
  # Execute the repo checker script
  echo "Running repo_sync.sh"
  "$REPO_CHECKER_SCRIPT"
  
  # Wait for 5 minutes before the next run
  echo "Waiting for 5 minutes..."
  sleep 300
done