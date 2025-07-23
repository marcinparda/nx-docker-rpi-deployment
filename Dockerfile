# Build stage
FROM node:20-alpine AS build

WORKDIR /app

# Optimize Nx for Docker environment
ENV NX_DAEMON=false
ENV NX_PARALLEL=1
ENV NX_SKIP_NX_CACHE=true
ENV CI=true

# Copy package files and configuration
COPY package*.json nx.json tsconfig*.json ./
RUN npm ci

# Copy source code
COPY . .

# Build all applications
RUN npx nx run-many --target=build --projects=app-1 --configuration=production

# Production stage
FROM nginx:alpine

# Copy built files for both apps
COPY --from=build /app/dist/apps/app-1 /usr/share/nginx/html/app-1

# Copy custom nginx config that will handle both apps
COPY nginx/multi-app.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 81
CMD ["nginx", "-g", "daemon off;"]
 