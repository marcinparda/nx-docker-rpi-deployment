# Nx Docker Production Deployment

This project demonstrates a practical approach to deploying multiple frontend applications from an Nx workspace to Raspberry Pi using Docker containers and Cloudflare. It maximizes the benefits of Nx's affected features for optimized CI/CD pipelines. The deployment process is automated using GitHub Actions workflows, which leverage Nx's dependency graph to only build, test, and deploy affected projects, resulting in fast and efficient deployments. The deployment to Raspberry Pi is performed via a secure Cloudflare tunnel and SSH, with Docker containers managed by a robust deployment script.

## 🎯 Overview

This is an example implementation of my deployment strategy that combines:

- **Nx monorepo** for efficient multi-app development
- **Docker containerization** for consistent deployment
- **Nginx** for serving multiple apps from a single container
- **GitHub Actions** for automated CI/CD with Nx affected commands
- **Raspberry Pi** as the target production environment

WARNING: I tested this solution only on react/vue/angular apps. For metaframeworks I am almost 100% sure it will not work out of the box, basing of how I seted up the Dockerfiles and Nginx configuration. You may need to adjust the Dockerfiles and Nginx configuration to suit your specific applications.

> **Note**: This approach works well for my use case, though it may not be the "perfect" solution. I'm open to improvements and may update this in the future.

## 🔄 CI/CD Pipeline & Deployment Workflows

This project uses several GitHub Actions workflows to automate validation, type generation, deployment, and code quality checks for the Nx monorepo. The workflows are designed to maximize speed by leveraging Nx's affected feature, so only changed projects are built and tested.

### Workflow Overview

#### 1. **Checks Workflow (`checks.yml`)**

- **Runs on:** Every pull request to `main` and on workflow calls.
- **Purpose:**
  - Installs dependencies
  - Finds the last successful deploy SHA
  - Runs `nx affected` for lint, build, and test on only changed projects
  - Ensures only relevant code is checked, speeding up PR validation

#### 2. **Deployment Workflow (`deploy.yml` & `deploy-to-production.yml`)**

- **`deploy.yml`:**

  - **Runs on:** Every push to `main`
  - **Purpose:**
    - Replaces dev URLs with production URLs in environment files
    - Installs dependencies
    - Finds the last successful deploy SHA
    - Runs `nx affected` for lint, build, and test on only changed projects
    - Builds and pushes Docker images for affected apps (e.g., app-1, app-2) to GHCR, only if their build output exists (THIS IS THE KEY PART)
    - Triggers deployment to Raspberry Pi via `deploy-to-production.yml`

- **`deploy-to-production.yml`:**
  - **Purpose:**
    - Sets up Cloudflare tunnel and SSH configuration
    - Copies the `deploy.sh` script to the Raspberry Pi
    - Executes the deployment script remotely, which pulls and runs the latest Docker images for all apps
    - Cleans up SSH keys and deployment script after deployment
    - Provides a deployment summary and troubleshooting tips

#### 3. **Deployment Script (`deploy.sh`)**

- **Location:** Root of repository
- **Purpose:** Handles the actual deployment of all apps on the Raspberry Pi. This script is copied and executed remotely by the `deploy-to-production.yml` workflow.
- **How it works:**
  - Requires `GITHUB_TOKEN` and `GITHUB_ACTOR` environment variables for authentication with GitHub Container Registry (GHCR).
  - Logs in to GHCR using the provided credentials.
  - Defines all apps to deploy with their respective ports.
  - For each app:
    - Stops and removes any existing container for the app
    - Prunes old Docker images
    - Pulls the latest image from GHCR
    - Runs the container on the correct port with restart policy
    - Performs a health check to ensure the container is running
  - If any container fails to start, logs are shown and the script exits with an error.
  - If all succeed, prints a success message.

**Note:** The script is designed for a single-node deployment (Raspberry Pi) and expects Docker to be installed and running. It is robust against missing containers/images and will always attempt to deploy the latest version of each app.

---

- All workflows use Node.js 20 and npm for dependency management.
- Docker images are built for `linux/arm64` and pushed to GitHub Container Registry (GHCR).
- Deployment is designed for a Raspberry Pi using Docker and Cloudflare Tunnel for secure SSH access.

#### Nx Affected Strategy

The pipeline leverages Nx's affected commands to:

- **Only build/test/lint projects that have changed** or depend on changed projects
- **Reduce CI/CD time** by skipping unnecessary work
- **Maintain confidence** by testing all affected dependencies

```bash
# Example: Only lint/test/build what's affected since last successful deployment
npx nx affected --targets=lint,build,test --base=<last-successful-sha> --head=HEAD
```

### 📊 Benefits of this Development and Deployment Approach

#### ✅ Nx Workspace Benefits

- **Shared libraries** between applications
- **Consistent tooling** (linting, testing, building)
- **Dependency graph** understanding for optimal builds (nx affected)
- **Code generation** for consistent project structure

#### ✅ Docker Containerization

- **Environment consistency** from development to production
- **Easy deployment** to any Docker-supported platform
- **Resource isolation** and scaling capabilities

#### ✅ Optimized CI/CD

- **Affected-only builds** reduce pipeline time
- **Automatic testing** of dependency chains
- **Container registry integration** with GHCR

#### ✅ Production-Ready

- **Nginx optimization** for static file serving
- **Multi-app support** in single container
- **Health checks** and monitoring capabilities

## 🚀 Getting Started

### Production Deployment

#### Pre-requisites

- Raspberry Pi with Docker installed
- Cloudflare Tunnel set up for remote access

#### Setup

0. Make sure you are using main as the default branch in your repository. If you use master or other named branches, you may need to adjust the workflows accordingly.
1. Fork or clone the repository.
2. Set up the following GitHub Actions secrets in your repository:
   - `CLOUDFLARE_TUNNEL_DOMAIN`: The domain for your Cloudflare tunnel
   - `RASPBERRY_PI_USERNAME`: The SSH username for your Raspberry Pi
   - `RASPBERRY_PI_SSH_KEY`: The private SSH key for your Raspberry Pi
   - `SSH_KNOWN_HOSTS`: The known hosts file from your Raspberry Pi
3. Push changes to the repository to trigger the CI/CD pipeline in GitHub Actions.

#### 🚨 Troubleshooting

**GitHub Actions Package Publishing Issues**

If you encounter the error:

```
buildx failed with: ERROR: failed to build: failed to solve: failed to push ghcr.io/marcinparda/nx-docker-rpi-deployment/nx-multi-app:latest: denied: installation not allowed to Create organization package
```

**Solution: Enable Package Permissions**

1. Go to your repository settings:
   - Navigate to `https://github.com/marcinparda/nx-docker-rpi-deployment/settings`
   - Go to `Actions → General`
   - Scroll down to "Workflow permissions"
   - Select "Read and write permissions"
   - Check "Allow GitHub Actions to create and approve pull requests"
   - Save the changes

### Local Development

#### Pre-requisites

- Node.js 20+
- npm
- Docker (for containerization)
- Docker Compose (for local development)

#### Installation

1. Clone the repository
   ```bash
   git clone <repository-url>
   cd nx-docker-rpi-deployment
   ```
2. Install dependencies
   ```bash
   npm ci
   ```
3. Start development servers

   ```bash
   # Start both apps in development mode
   npx nx serve app-1
   npx nx serve app-2

   # Or run in parallel
   npx nx run-many --target=serve --projects=app-1,app-2
   ```

#### Docker Start Command

```bash
# Local development
docker-compose up --build
```

## 🐳 Configuration

When using this example for your own Nx workspace, you may need to adjust the following:

1. **Modify Dockerfiles**
   - Update the images of apps if needed on `apps/<app-name>/Dockerfile`
2. **Update Nginx Configuration**
   - Modify `apps/<app-name>/nginx/<app-name>.conf` to include your applications
3. **Adjust GitHub Actions Workflows**
   - Update workflow files in `.github/workflows/` to match your repository and application structure
   - In `.github/workflows/README.md`, you can find info about how to add new app to the deployment process
   - Add additional checks or remove unnecessary ones from the `checks.yml` file
   - Update image names in Docker build steps to match your project
   - Adjust platforms if you need to support different architectures (e.g. `linux/amd64,linux/arm64`). In this example, deployment targets Raspberry Pi (`linux/arm64`).
   - When using the `deploy-to-production.yml`, use the images built by the main workflow
4. **Update Deployment Script**
   - Modify `deploy.sh` to suit your deployment needs

## 🎯 How to Deploy to a Different Target Than Raspberry Pi

Edit the `deploy-to-production.yml` workflow file to suit your target environment. Remember to use images built by the main workflow for deployment.

## 🤝 Contributing

This is a personal example project, but suggestions and improvements are welcome! Feel free to:

- Open issues for questions or suggestions
- Submit pull requests for improvements
- Share your own deployment strategies

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Note**: This approach represents my current deployment strategy and has proven effective for my use cases. While it may not be the optimal solution for every scenario, it successfully combines Nx's powerful affected features with Docker's containerization benefits for efficient CI/CD pipelines.
