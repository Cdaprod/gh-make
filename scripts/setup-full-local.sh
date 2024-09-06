#!/bin/bash

# Set environment variables
ROOT_DIR="${HOME}/cdaprod"
HOOKS_DIR="${PWD}/hooks"  # Assuming the hooks are in the "hooks" directory relative to the script's location

# Function to install hooks into a single repository
install_hooks() {
  local repo_path="$1"
  echo "Installing hooks in repository: $repo_path"

  # Copy hooks to the .git/hooks directory of the repo
  for hook in "$HOOKS_DIR"/*; do
    hook_name=$(basename "$hook")
    cp "$hook" "$repo_path/.git/hooks/$hook_name"
    chmod +x "$repo_path/.git/hooks/$hook_name"
  done

  echo "Hooks installed in $repo_path"
}

# Recursively find all .git directories and install hooks
find_repos_recursive() {
  local dir="$1"
  find "$dir" -type d -name ".git" | while read -r git_dir; do
    repo_path=$(dirname "$git_dir")
    install_hooks "$repo_path"
  done

  # Check for subdirectories that might also contain more repositories
  find "$dir" -type d ! -path "$dir" -print | while read -r subdir; do
    find_repos_recursive "$subdir"
  done
}

# Start recursive search and hook installation
find_repos_recursive "$ROOT_DIR"

echo "Setup complete. All hooks installed."