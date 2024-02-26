# Stage 1
FROM alpine:latest AS build

ARG BASE_URL="http://localhost"

# Install the Hugo go app.
RUN apk add --update hugo

WORKDIR /opt/HugoApp

# Copy Hugo config into the container Workdir.
COPY . .

# Set Hugo envs.
ENV HUGO_ENVIRONMENT=production \
    HUGO_ENV=production

# Run Hugo in the Workdir to generate HTML.
RUN hugo --gc --minify --baseURL $BASE_URL     

# Stage 2
FROM nginx:1.25-alpine

# Set workdir to the NGINX default dir.
WORKDIR /usr/share/nginx/html

# Copy HTML from previous build into the Workdir.
COPY --from=build /opt/HugoApp/public .

# Expose port 80
EXPOSE 80/tcp
