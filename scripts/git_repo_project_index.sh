#!/bin/bash

# Set environment variables
ROOT_DIR="${HOME}/cdaprod"
GITHUB_TOKEN="$GH_TOKEN"  # Get from environment variable
PROJECT_ID="24"  # Replace with your actual project ID
COLUMN_NAME="Module"
COLUMN_DESCRIPTION="This column is for indexing repositories by modules."
ORG_NAME="Cdaprod"  # GitHub organization or username

# Initialize an output file to store repository information temporarily
OUTPUT_FILE="${HOME}/git_repo_index.json"
echo "[" > "$OUTPUT_FILE"

# Function to check if column exists and create it if necessary
create_column_if_not_exists() {
  existing_column_id=$(gh api graphql -f query='
    query($project: ID!) {
      node(id: $project) {
        ... on ProjectV2 {
          columns(first: 100) {
            nodes {
              id
              name
            }
          }
        }
      }
    }' -F project="$PROJECT_ID" --jq ".data.node.columns.nodes[] | select(.name == \"$COLUMN_NAME\") | .id")

  if [ -z "$existing_column_id" ]; then
    echo "Creating new column: $COLUMN_NAME"
    gh api graphql -f query='
      mutation($project: ID!, $name: String!) {
        addProjectV2ItemById(input: {projectId: $project, content: $name}) {
          id
        }
      }' -f project="$PROJECT_ID" -f name="$COLUMN_NAME"
    echo "Setting description for column: $COLUMN_NAME"
    gh api graphql -f query='
      mutation($column: ID!, $description: String!) {
        updateProjectV2ItemField(input: {itemId: $column, description: $description}) {
          projectV2Item {
            id
          }
        }
      }' -f column="$existing_column_id" -f description="$COLUMN_DESCRIPTION"
  else
    echo "Column $COLUMN_NAME already exists."
  fi
}

# Function to index a single repository
index_repo() {
  local repo_path="$1"
  echo "Indexing repository at: $repo_path"
  
  # Navigate to the repository
  cd "$repo_path" || return

  # Get repository information
  repo_name=$(basename "$repo_path")
  repo_url=$(git config --get remote.origin.url)
  last_commit=$(git log -1 --pretty=format:"%h - %s (%ci)")

  # Add repository information to the output file
  echo "{" >> "$OUTPUT_FILE"
  echo "  \"name\": \"$repo_name\"," >> "$OUTPUT_FILE"
  echo "  \"path\": \"$repo_path\"," >> "$OUTPUT_FILE"
  echo "  \"url\": \"$repo_url\"," >> "$OUTPUT_FILE"
  echo "  \"last_commit\": \"$last_commit\"" >> "$OUTPUT_FILE"
  echo "}," >> "$OUTPUT_FILE"

  # Use GitHub CLI to add repo to GitHub Project
  gh api graphql -f query='
  mutation($project:ID!, $repoUrl:String!) {
    addProjectV2ItemById(input: {projectId: $project, contentId: $repoUrl}) {
      item {
        id
      }
    }
  }' -f project="$PROJECT_ID" -f repoUrl="$repo_url" --jq '.data.addProjectV2ItemById.item.id'
}

# Recursively find all .git directories and index the repositories
find_repos_recursive() {
  local dir="$1"
  find "$dir" -type d -name ".git" | while read -r git_dir; do
    repo_path=$(dirname "$git_dir")
    index_repo "$repo_path"
  done

  # Check for subdirectories that might also contain more repositories
  find "$dir" -type d ! -path "$dir" -print | while read -r subdir; do
    find_repos_recursive "$subdir"
  done
}

# Check if column exists and create if not
create_column_if_not_exists

# Start recursive search and indexing
find_repos_recursive "$ROOT_DIR"

# Finalize the output file
echo "]" >> "$OUTPUT_FILE"

echo "Indexing complete. Repository information saved to $OUTPUT_FILE."