FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE port 80
CMD ["nginx", "-g", "daemon off;"]
