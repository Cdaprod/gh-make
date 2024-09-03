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

## Demonstration

To create a new workflow in your repository `Cdaprod/AI-Frontend` that uses the GitVersion workflow template and runs on multiple branches (`main`, `typescript/nextjs`, and `next/styling`), you need to set up a new workflow YAML file in the `.github/workflows/` directory of your repository.

### Step-by-Step Instructions

1. **Create a New Workflow File**:
   - In your `Cdaprod/AI-Frontend` repository, navigate to the `.github/workflows/` directory.
   - Create a new workflow file, for example, `use-gitversion-template.yml`.

2. **Define the Workflow Using the Template**:
   - In the new YAML file, reference your workflow template and specify the branches you want to use as inputs. Here’s how you can structure your new workflow file:

### Example Workflow (`use-gitversion-template.yml`)

```yaml
name: Use GitVersion Workflow

on:
  push:
    branches:
      - main
      - typescript/nextjs
      - next/styling
  pull_request:
    branches:
      - main
      - typescript/nextjs
      - next/styling

jobs:
  use-template:
    uses: Cdaprod/.github/workflow-templates/gitversion-docker-build.yml@main
    with:
      branches: |
        main
        typescript/nextjs
        next/styling
```

### Explanation of the Workflow

- **`on` Trigger**:
  - The workflow triggers on both `push` and `pull_request` events to the specified branches (`main`, `typescript/nextjs`, `next/styling`). This means the workflow will run whenever there are commits pushed to or pull requests opened/merged into any of these branches.

- **`jobs` Section**:
  - **`use-template`**: This job uses the workflow template defined in your organization repository (`Cdaprod/.github/workflow-templates/gitversion-docker-build.yml@main`).
  - **`with` Parameters**: 
    - The `branches` parameter is set to a multiline string that specifies all branches you want this workflow to run on. The GitVersion workflow will use this list to determine which branches to apply versioning rules to.

### Benefits of This Setup

- **Centralized Management**: By using a workflow template, you centralize your CI/CD logic in one place. Updates to the template automatically propagate to all repositories using it.
- **Consistent Workflow Execution**: Ensures that the same versioning and Docker image build processes are applied across all branches in all repositories using this setup.
- **Easy to Extend**: If you add new branches or modify branch policies, you only need to update the workflow file in the repository, not the template itself.

### Next Steps

- **Push the Workflow File**: Commit and push the new workflow file (`use-gitversion-template.yml`) to your `Cdaprod/AI-Frontend` repository.
- **Monitor Workflow Runs**: Once the workflow file is in place, any new pushes or pull requests to the specified branches should trigger the GitVersion workflow, which will handle versioning and Docker image building according to your setup.

This configuration ensures that your versioning strategy is consistently applied across your development branches, giving you a "set it and forget it" experience while maintaining flexibility and control.