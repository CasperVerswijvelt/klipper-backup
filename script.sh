#!/usr/bin/env bash

# Set parent directory path
parent_path=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)

# Initialize variables from .env file
github_token=$(grep 'github_token=' "$parent_path"/git.env | sed 's/^.*=//')
github_username=$(grep 'github_username=' "$parent_path"/git.env | sed 's/^.*=//')
github_repository=$(grep 'github_repository=' "$parent_path"/git.env | sed 's/^.*=//')

echo "$github_token"
echo "$github_username"
echo "$github_repository"

backup_folder="backup_repo"

# Change directory to parent path
cd "$parent_path" || exit

# Check if backup folder exists, create one if it does not
if [ ! -d "$parent_path/$backup_folder" ]; then
  mkdir "$parent_path/$backup_folder"
  cat "$parent_path/.env.example"
  cp "$parent_path/.env.example" "$parent_path/$backup_folder/.env"
  (cd "$backup_folder" && git init && git commit -am "Initial commit")
fi

# Copy important files into backup folder
while read -r path; do
  echo "$path"
  file=$(basename "$path")
  mkdir -p "$parent_path/$backup_folder/config"
  cp -r "$path" "$parent_path/$backup_folder/config"
done < <(grep -v '^#' "$parent_path"/"$backup_folder"/.env | grep 'path_' | sed 's/^.*=//')


# Individual commit message, if no parameter is set, use the current timestamp as commit message
if [ -n "$1" ]; then
    commit_message="$1"
else
    commit_message="New backup from $(date +"%d-%m-%y")"
fi

# Git commands
#git init
#git filter-branch --force --index-filter \
#  'git rm -r --cached --ignore-unmatch "$parent_path"/.env' \
#  --prune-empty --tag-name-filter cat -- --all
#git rm -rf --cached "$parent_path"/.env
cd "$backup_folder"
git add .
git commit -m "$commit_message"
git push https://"$github_token"@github.com/"$github_username"/"$github_repository".git main
