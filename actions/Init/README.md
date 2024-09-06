Here is the complete `action.yml` file for your **Init** action, taking into account your expanded requirements. This action detects the project language, initializes the project with the appropriate environment scripts, ensures the proper Dockerfile is used, and handles DockerHub login and pushing of multi-architecture images.

### `Cdaprod/.github/actions/Init/action.yml`

```yaml
name: 'Init'
description: 'Initialize the repository by detecting project language and running environment-specific scripts from a central repo'
author: 'cdaprod'

inputs:
  dockerhub_username:
    description: 'DockerHub username to push images'
    required: true
  dockerhub_token:
    description: 'DockerHub token for authentication'
    required: true
  env_repo_url:
    description: 'URL of the central environment repository'
    default: 'https://github.com/Cdaprod/env-repo.git'
    required: false

runs:
  using: 'composite'
  steps:
    # Step 1: Checkout the project repository
    - name: Checkout repository
      uses: actions/checkout@v2
      with:
        fetch-depth: 0

    # Step 2: Clone the environment repository
    - name: Clone environment repository
      run: |
        git clone ${{ inputs.env_repo_url }} .env

    # Step 3: Detect the project language by running the detection script
    - name: Detect project language
      run: ./.env/.github/environments/detect_language.sh

    # Step 4: Initialize environment based on detected language (Go or Python)
    - name: Run initialization script based on detected language
      run: |
        case ${{ env.DETECTED_LANGUAGE }} in
          go)
            echo "Initializing Go project..."
            chmod +x .env/.github/environments/.go/init
            .env/.github/environments/.go/init
            ;;
          python)
            echo "Initializing Python project..."
            chmod +x .env/.github/environments/.py/init
            .env/.github/environments/.py/init
            ;;
          *)
            echo "Unsupported language detected or no language detected."
            exit 1
            ;;
        esac

    # Step 5: Check for an existing Dockerfile in the project
    - name: Check for Dockerfile in the repository
      id: check_dockerfile
      run: |
        if [ -f "Dockerfile" ]; then
          echo "DOCKERFILE_EXISTS=true" >> $GITHUB_ENV
        else
          echo "DOCKERFILE_EXISTS=false" >> $GITHUB_ENV
        fi

    # Step 6: Run build script and ensure Dockerfile is used (default if none found)
    - name: Run build script based on detected language and use appropriate Dockerfile
      run: |
        case ${{ env.DETECTED_LANGUAGE }} in
          go)
            echo "Building Go project..."
            chmod +x .env/.github/environments/.go/build
            if [ ${{ env.DOCKERFILE_EXISTS }} == "false" ]; then
              echo "No Dockerfile found, using default Go Dockerfile..."
              cp .env/.github/environments/.go/Dockerfile Dockerfile
            fi
            .env/.github/environments/.go/build
            ;;
          python)
            echo "Building Python project..."
            chmod +x .env/.github/environments/.py/build
            if [ ${{ env.DOCKERFILE_EXISTS }} == "false" ]; then
              echo "No Dockerfile found, using default Python Dockerfile..."
              cp .env/.github/environments/.py/Dockerfile Dockerfile
            fi
            .env/.github/environments/.py/build
            ;;
          *)
            echo "Unsupported or no language detected for building."
            exit 1
            ;;
        esac

    # Step 7: Log in to DockerHub using the provided credentials
    - name: Log in to DockerHub
      run: echo ${{ inputs.dockerhub_token }} | docker login -u ${{ inputs.dockerhub_username }} --password-stdin

    # Step 8: Build and push multi-architecture Docker image
    - name: Build and push multi-arch Docker image
      run: |
        docker buildx build --platform linux/amd64,linux/arm64 \
        -t ${{ inputs.dockerhub_username }}/${{ github.repository }}:latest \
        --push .
```

### **Explanation of the Steps:**

1. **Checkout Repository**: This step fetches the project’s repository to initialize.
2. **Clone Environment Repository**: Clones the central environment repository (`env-repo`) where your environment-specific scripts are stored.
3. **Detect Project Language**: Uses the `detect_language.sh` script to identify the project's programming language (Go or Python) and exports this as the environment variable `DETECTED_LANGUAGE`.
4. **Run Initialization Script**: Based on the detected language, this runs the appropriate `init` script (`.py/init` for Python, `.go/init` for Go).
5. **Check for Dockerfile**: This step checks if a `Dockerfile` exists in the repository. If it does, it sets `DOCKERFILE_EXISTS=true`; otherwise, it sets `DOCKERFILE_EXISTS=false`.
6. **Run Build Script**: Depending on the language and whether a `Dockerfile` exists, this either copies a default Dockerfile from the environment repo or runs the `build` script to prepare the project for Dockerization.
7. **Log in to DockerHub**: Logs into DockerHub using the credentials provided via inputs.
8. **Build and Push Multi-Arch Docker Image**: This step builds and pushes a multi-architecture Docker image (`linux/amd64` and `linux/arm64`) to DockerHub.

### **Usage Example:**

To use this action in a workflow, you would include a job like the following:

```yaml
name: Initialize Project and Push to DockerHub

on: [push]

jobs:
  init-project:
    runs-on: ubuntu-latest
    steps:
      - name: Initialize and Dockerize Project
        uses: Cdaprod/.github/actions/Init@main
        with:
          dockerhub_username: ${{ secrets.DOCKERHUB_USERNAME }}
          dockerhub_token: ${{ secrets.DOCKERHUB_TOKEN }}
          env_repo_url: 'https://github.com/Cdaprod/env-repo.git'
```

This ensures the action initializes the environment, builds the Docker image, and pushes it to DockerHub.

### **Further Customization:**
Would you like to extend this action to support other languages, or add more customization for different environments? Feel free to suggest additional functionality!