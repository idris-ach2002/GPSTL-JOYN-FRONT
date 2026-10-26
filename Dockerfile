ARG FLUTTER_IMAGE=ghcr.io/cirruslabs/flutter:stable
FROM ${FLUTTER_IMAGE} AS build

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

ARG JOYN_DATA_MODE=auto
ARG JOYN_API_BASE_URL=
ARG JOYN_API_TIMEOUT_MS=12000

RUN flutter build web --release \
    --dart-define=JOYN_DATA_MODE=${JOYN_DATA_MODE} \
    --dart-define=JOYN_API_BASE_URL=${JOYN_API_BASE_URL} \
    --dart-define=JOYN_API_TIMEOUT_MS=${JOYN_API_TIMEOUT_MS}

FROM nginx:1.27-alpine
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1/healthz || exit 1
