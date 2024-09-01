#!/bin/bash

echo "Detecting project language..."

# Initialize a variable to store the detected language
DETECTED_LANGUAGE="unknown"

# Check for Go project (look for go.mod)
if [ -f "go.mod" ]; then
  DETECTED_LANGUAGE="go"
  echo "Detected Go project based on go.mod file."

# Check for Python project (look for requirements.txt)
elif [ -f "requirements.txt" ]; then
  DETECTED_LANGUAGE="python"
  echo "Detected Python project based on requirements.txt file."

# Check for Node.js project (look for package.json)
elif [ -f "package.json" ]; then
  DETECTED_LANGUAGE="nodejs"
  echo "Detected Node.js project based on package.json file."

else
  echo "No recognized project files found. Language is indeterminate."
fi

# Export detected language as an environment variable
echo "DETECTED_LANGUAGE=$DETECTED_LANGUAGE" >> $GITHUB_ENV