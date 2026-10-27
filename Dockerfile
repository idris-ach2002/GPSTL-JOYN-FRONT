# syntax=docker/dockerfile:1

FROM --platform=linux/amd64 debian:bookworm-slim AS build
ARG FLUTTER_VERSION=3.47.8

ENV DEBIAN_FRONTEND=noninteractive \
    CI=true \
    FLUTTER_SUPPRESS_ANALYTICS=true \
    PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       curl \
       git \
       unzip \
       xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fL \
      "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
      -o /tmp/flutter.tar.xz \
    && mkdir -p /opt \
    && tar -xJf /tmp/flutter.tar.xz -C /opt \
    && rm /tmp/flutter.tar.xz \
    && git config --global --add safe.directory /opt/flutter \
    && flutter --version \
    && dart --version \
    && flutter config --enable-web \
    && flutter precache --web

WORKDIR /app

# Cache des dépendances Dart/Flutter.
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Sources de l'application.
COPY . .

# Production Flutter Web à la racine du domaine.
RUN flutter build web --release --base-href /

FROM --platform=linux/amd64 nginx:1.27-alpine
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
