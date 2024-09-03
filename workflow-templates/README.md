To use the `docker-build-tag-push-gitversion.yml` workflow-template in a repository, implement the following workflow in said repo:

```
name: Use GitVersion Workflow

on:
  workflow_call:
    inputs:
      branches:
        required: true
        default: 'main'

jobs:
  use-template:
    uses: Cdaprod/.github/workflow-templates/gitversion-docker-build.yml@main
    with:
      branches: ${{ inputs.branches }}
```