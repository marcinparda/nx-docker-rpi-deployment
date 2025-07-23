# Build stage
FROM node:20-alpine AS build

WORKDIR /app

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
COPY --from=build /app/dist/apps/app-2 /usr/share/nginx/html/app-2

# Copy custom nginx config that will handle both apps
COPY nginx/multi-app.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 81
CMD ["nginx", "-g", "daemon off;"]
