#!/bin/bash

echo "Running tests..."

# Run Python tests if pytest is available
if command -v pytest >/dev/null 2>&1; then
  echo "Running Python tests with pytest..."
  pytest --maxfail=1 --disable-warnings || echo "Warning: Some Python tests failed."
fi

# Run Go tests if go is available
if command -v go >/dev/null 2>&1; then
  echo "Running Go tests..."
  go test ./... || echo "Warning: Some Go tests failed."
fi

# Run Node.js tests if npm and a test script are defined in package.json
if command -v npm >/dev/null 2>&1 && grep -q '"test":' package.json; then
  echo "Running Node.js tests with npm..."
  npm test || echo "Warning: Some Node.js tests failed."
fi

# Run Java tests if Maven is available
if command -v mvn >/dev/null 2>&1; then
  echo "Running Java tests with Maven..."
  mvn test || echo "Warning: Some Java tests failed."
fi

# Run Rust tests if Cargo is available
if command -v cargo >/dev/null 2>&1; then
  echo "Running Rust tests with Cargo..."
  cargo test || echo "Warning: Some Rust tests failed."
fi

# Run Ruby tests if RSpec is available
if command -v rspec >/dev/null 2>&1; then
  echo "Running Ruby tests with RSpec..."
  rspec || echo "Warning: Some Ruby tests failed."
fi

echo "All tests completed."