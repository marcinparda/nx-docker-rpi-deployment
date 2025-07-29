FROM nginx:alpine

# Copy built files for the app-1 app
COPY  dist/apps/app-1 /usr/share/nginx/html

# Copy custom nginx config that will handle both apps
COPY apps/app-1/nginx/app-1.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
