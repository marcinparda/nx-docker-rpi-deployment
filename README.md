# Nx Docker Production Deployment

This project demonstrates a practical approach to deploying multiple frontend applications from an Nx workspace to Raspberry Pi using Docker containers and Cloudflare. Trying to maximize the benefits of Nx's affected features for optimized CI/CD pipelines. The goal is to provide fast and efficient deployment processes that will connect to raspberry pi devices via Cloudflare tunnel for as short as possible time to avoid ssh connection issues.

## 🎯 Overview

This is an example implementation of my deployment strategy that combines:

- **Nx monorepo** for efficient multi-app development
- **Docker containerization** for consistent deployment
- **Nginx** for serving multiple apps from a single container
- **GitHub Actions** for automated CI/CD with Nx affected commands
- **Raspberry Pi** as the target production environment

> **Note**: This approach works well for my use case, though it may not be the "perfect" solution. I'm open to improvements and may update this in the future.

## 🔄 CI/CD Pipeline

The project uses GitHub Actions with a focus on Nx's affected commands to optimize build and deployment times.

### Workflow Overview

1. **Code Quality Checks** (`checks.yml`)

   - Runs on pull requests to master
   - Finds the last commit on the main branch with successful deployment
   - Executes `nx affected --targets=lint,build,test` to only check changed projects compared to the last successful deployment
   - Uses Nx's dependency graph to understand what needs testing

2. **Image Building** (`build-images.yml`)

   - Builds Docker images with multi-stage builds
   - Pushes to GitHub Container Registry (GHCR)
   - Tags with both `latest` and commit SHA
   - Logging the build status to GitHub Actions summary

3. **Production Deployment** (`deploy-to-production.yml`)
   - Setting up access to Raspberry Pi (Cloudflare and SSH)
   - Copies the `deploy.sh` script to the Raspberry Pi
   - Running the `deploy.sh` script on the Raspberry Pi
   - `deploy.sh` script handles:
     - Pulling the latest Docker images
     - Stopping and removing existing container
     - Starting new container with the latest image
   - Cleans up `~/.ssh/id_rsa` and `deploy.sh` files after deployment
   - Logging the deployment status to GitHub Actions summary

### Nx Affected Strategy

The pipeline leverages Nx's affected commands to:

- **Only build/test/lint projects that have changed** or depend on changed projects
- **Reduce CI/CD time** by skipping unnecessary work
- **Maintain confidence** by testing all affected dependencies

```bash
# Example: Only lint/test/build what's affected since main branch
npx nx affected --targets=lint,build,test --base=origin/main --head=HEAD
```

### 📊 Benefits of this development and deployment apprach:

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

#### Testing the example

1. Fork or clone the repository.

2. Setup the environments
   For deployment on GitHub actions you need to setup your repository with these actions secrets configured:

- `CLOUDFLARE_TUNNEL_DOMAIN`: The domain for your Cloudflare tunnel
- `RASPBERRY_PI_USERNAME`: The SSH username for your Raspberry Pi
- `RASPBERRY_PI_SSH_KEY`: The private SSH key for your Raspberry Pi
- `SSH_KNOWN_HOSTS`: The known hosts file from your Raspberry Pi

3. You can try to push some changes to the repository to trigger the CI/CD pipeline in GitHub Actions.

#### 🚨 Troubleshooting

**GitHub Actions Package Publishing Issues**

If you encounter the error:

```
buildx failed with: ERROR: failed to build: failed to solve: failed to push ghcr.io/marcinparda/nx-docker-rpi-deployment/nx-multi-app:latest: denied: installation not allowed to Create organization package
```

**Solution: Enable Package Permissions**

1. **Go to your repository settings:**
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

1. **Modify Dockerfile**

- Update the base image if needed
- Adjust build steps for your applications

2. **Update `docker-compose.yml`**

- Change service names and ports to match your applications

3. **Update Nginx Configuration**

- Modify `nginx/multi-app.conf` to include your applications
- Configure routing and other settings as necessary

4. **Adjust GitHub Actions Workflows**

- Update workflow files in `.github/workflows/` to match your repository and application structure
- Add additional checks or remove unnecessary ones from the `checks.yml` file
- Update image names in `build-images.yml` (e.g. `nx-multi-app`) to match your project
- In `build-images.yml` adjust platforms if you need to support different architectures (e.g. `linux/amd64,linux/arm64`), you can remove the `platforms` line if you want to build only for the current architecture which is usually the best option if you don't have a specific need for multi-architecture builds. In this example I am deploying to Raspberry Pi which requires `linux/arm64` support.
- When using the `deploy-to-production.yml`, use the images built by the `build-images.yml` workflow

5. **Update Deployment Script**

- Modify `deploy.sh` to suit your deployment needs

## 🎯 How to deploy to something different than Raspberry Pi

Just edit the `deploy-to-production.yml` workflow file

Remember about using images built by the `build-images.yml` workflow if you will use this step.

## 🤝 Contributing

This is a personal example project, but suggestions and improvements are welcome! Feel free to:

- Open issues for questions or suggestions
- Submit pull requests for improvements
- Share your own deployment strategies

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Note**: This approach represents my current deployment strategy and has proven effective for my use cases. While it may not be the optimal solution for every scenario, it successfully combines Nx's powerful affected features with Docker's containerization benefits for efficient CI/CD pipelines.
