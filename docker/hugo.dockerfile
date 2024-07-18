# Stage 1: Download HUGO + build static site. 
FROM alpine:latest AS build
RUN apk add --no-cache wget
ARG HUGO_VERSION="0.128.2"

RUN wget --quiet "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz" && \
    tar xzf hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
    rm -r hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
    mv hugo /usr/bin && \
    chmod 755 /usr/bin/hugo

WORKDIR /src
COPY ./hugo/ /src

RUN mkdir /target && \
    hugo -d /target

# Stage 2: Serve the generated html using nginx
FROM nginxinc/nginx-unprivileged:stable-alpine

RUN sed -i '3 a\    absolute_redirect off;' /etc/nginx/conf.d/default.conf && \
    sed -i 's/#error_page  404/error_page  404/' /etc/nginx/conf.d/default.conf

COPY --from=build /target /usr/share/nginx/html
EXPOSE 8080
