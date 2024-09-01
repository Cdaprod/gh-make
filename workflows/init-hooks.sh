name: Initialize Git Hooks

on:
  push:
    branches:
      - main

jobs:
  setup-hooks:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v2

      - name: Set up GitHub CLI
        run: |
          sudo apt-get install gh
          gh auth login --with-token ${{ secrets.GITHUB_TOKEN }}

      - name: Add .github remote
        run: git remote add github-config git@github.com:Cdaprod/.github.git

      - name: Fetch and apply hooks
        run: |
          git fetch github-config
          git checkout github-config/main -- .github/hooks
          chmod +x .github/hooks/*
          cp .github/hooks/* .git/hooks/
          echo "Git hooks have been set up successfully."

      - name: Run setup-hooks script
        run: bash setup-hooks.sh