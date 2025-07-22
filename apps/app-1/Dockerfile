# Build stage
FROM node:20-alpine AS build

WORKDIR /app

# Copy package files and configuration
COPY package*.json nx.json tsconfig*.json ./
RUN npm ci

# Copy source code
COPY . .

# Build the application (Nx will automatically build dependencies)
RUN npx nx build app-1 --configuration=production

# Production stage
FROM nginx:alpine

# Copy built files
COPY --from=build /app/dist/apps/app-1 /usr/share/nginx/html

# Copy nginx config
COPY apps/app-1/nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
