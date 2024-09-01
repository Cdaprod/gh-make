# setup-hooks.sh

# Add .github as a remote if it's not already present
git remote | grep 'github-config' || git remote add github-config git@github.com:Cdaprod/.github.git

# Fetch the latest hooks
git fetch github-config

# Checkout the hooks
git checkout github-config/main -- .github/hooks

# Make hooks executable
chmod +x .github/hooks/*

# Copy hooks to the .git/hooks directory
cp .github/hooks/* .git/hooks/

echo "Hooks setup complete."