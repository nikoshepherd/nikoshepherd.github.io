# Stage 1
FROM alpine:latest AS build

ARG BASE_URL="http://localhost" \
    GPG_PUBLIC_KEY \
    GPG_RECIPIENT

# Install the Hugo go app.
RUN apk add --update hugo gpg gpg-agent

WORKDIR /opt/HugoApp

# Copy Hugo config into the container Workdir.
COPY . .

# Set Hugo envs.
ENV HUGO_ENVIRONMENT=production \
    HUGO_ENV=production

# Run Hugo in the Workdir to generate HTML.
RUN hugo --gc --minify --baseURL $BASE_URL \
    && echo -n "$GPG_PUBLIC_KEY" | base64 -d | gpg --import \
    && tar czf site.tgz -C public . \
    && gpg --encrypt --trust-model always --recipient $GPG_RECIPIENT site.tgz


# Stage 2
FROM nginx:1.25-alpine
RUN apk add gpg gpg-agent 

# Set workdir to the NGINX default dir.
WORKDIR /usr/share/nginx/html

# Copy HTML from previous build into the Workdir.
COPY --from=build /opt/HugoApp/site.tgz.gpg .
COPY --from=build /opt/HugoApp/build/decrypt.sh /docker-entrypoint.d
# Expose port 80
EXPOSE 80/tcp

