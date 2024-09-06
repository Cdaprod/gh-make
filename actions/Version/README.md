Here is the `action.yml` for the version tagging action that you requested at the path `Cdaprod/.github/actions/Version/action.yml`:

### `Version/action.yml`

```yaml
name: 'Version'
description: 'Tag version using GitVersion without pushing any images'
author: 'cdaprod'
inputs:
  tag_message:
    description: 'The message for the Git tag'
    required: false
    default: 'Auto-generated version tag'

runs:
  using: 'composite'
  steps:
    - name: Checkout repository
      uses: actions/checkout@v2
      with:
        fetch-depth: 0  # Fetch full history for versioning

    - name: Install GitVersion
      uses: gittools/actions/gitversion/setup@v0.9.7
      with:
        versionSpec: '5.x'

    - name: Run GitVersion
      id: gitversion
      uses: gittools/actions/gitversion/execute@v0.9.7

    - name: Tag version
      run: |
        git config user.name "github-actions"
        git config user.email "github-actions@github.com"
        git tag v${{ steps.gitversion.outputs.semVer }} -m "${{ inputs.tag_message }}"
        git push origin v${{ steps.gitversion.outputs.semVer }}

branding:
  icon: 'tag'
  color: 'green'
```

### How to Use the `Version` Action

To invoke this version tagging action in your workflow, use the following configuration:

```yaml
name: Version Tagging

on:
  push:
    branches:
      - main
      - develop
      - release/**

jobs:
  version-tag:
    runs-on: ubuntu-latest
    steps:
      - name: Run Version Tagging Action
        uses: Cdaprod/.github/.github/actions/Version@main
        with:
          tag_message: 'This is a version tag for the new release'
```

### What This Action Does:
- **Checks out** the code.
- **Installs and runs GitVersion** to determine the correct semantic version.
- **Creates a tag** for the calculated version and pushes it to the repository.
