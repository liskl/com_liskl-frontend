# Use a lightweight image of Nginx
FROM nginx:alpine

# Copy the contents of the site directory to the default Nginx document root
COPY site /usr/share/nginx/html

# Expose port 80 for HTTP traffic
EXPOSE 80

# Start Nginx in the foreground when the container starts
CMD ["nginx", "-g", "daemon off;"]
