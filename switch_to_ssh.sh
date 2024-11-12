#!/bin/bash

# Set the parent directory to the first argument or default to the current directory
PARENT_DIR="${1:-.}"

# Iterate through each subdirectory in the specified directory
for dir in "$PARENT_DIR"/*; do
  # Check if the directory is a valid Git repository
  if [ -d "$dir/.git" ]; then
    echo "Found Git repository in: $dir"

    # Change to the repository directory
    cd "$dir" || continue

    # Get the current remote URL (we assume there's only one remote named 'origin')
    REMOTE_URL=$(git remote get-url origin)

    # Check if the remote URL is an HTTPS URL
    if [[ "$REMOTE_URL" =~ ^https://github.com/ ]]; then
      echo "Changing remote URL from HTTPS to SSH for: $dir"

      # Replace HTTPS URL with SSH URL
      SSH_URL=$(echo "$REMOTE_URL" | sed 's/https:\/\/github.com\//git@github.com:/')

      # Set the new SSH URL as the remote URL
      git remote set-url origin "$SSH_URL"
      echo "New remote URL: $SSH_URL"
    else
      echo "No HTTPS remote found or already using SSH for: $dir"
    fi

    # Go back to the parent directory
    cd - > /dev/null || exit
  else
    echo "Skipping non-Git directory: $dir"
  fi
done

echo "Done updating remotes."
