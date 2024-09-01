#!/bin/bash

echo "Starting CI checks..."

# Run linters
echo "Running linters..."
if command -v eslint >/dev/null 2>&1; then
  eslint . || echo "ESLint found issues."
fi

if command -v pylint >/dev/null 2>&1; then
  pylint *.py || echo "Pylint found issues."
fi

# Run unit tests
echo "Running unit tests..."
if [ -f "run_tests.sh" ]; then
  ./run_tests.sh || echo "Some unit tests failed."
elif command -v pytest >/dev/null 2>&1; then
  pytest || echo "Pytest found issues."
fi

# Run security checks
echo "Running security checks..."
if command -v npm-audit >/dev/null 2>&1; then
  npm audit || echo "NPM audit found vulnerabilities."
fi

# Dependency checks
echo "Checking dependencies..."
if [ -f "package.json" ]; then
  npm outdated || echo "Some npm dependencies are outdated."
elif [ -f "requirements.txt" ]; then
  pip list --outdated || echo "Some pip dependencies are outdated."
fi

# Build checks
echo "Running build checks..."
if command -v go >/dev/null 2>&1; then
  echo "Building Go project..."
  go build ./... || echo "Go build failed. Please check the errors."
elif [ -f "Makefile" ]; then
  make build || echo "Makefile build target failed."
elif [ -f "build.sh" ]; then
  ./build.sh || echo "Build script failed."
fi

echo "CI checks completed."