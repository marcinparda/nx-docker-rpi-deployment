FROM nginx:alpine

# Copy built files for the app-2 app
COPY  dist/apps/app-2 /usr/share/nginx/html

# Copy custom nginx config that will handle both apps
COPY apps/app-2/nginx/app-2.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
