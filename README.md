# Tengine 3.1.0 Fancyindex Docker Image

A production-ready Docker image for **Tengine 3.1.0** with advanced directory listing and media preview capabilities.

## Overview

This image compiles **Tengine 3.1.0** from source and integrates:

- [Fancyindex](https://github.com/TheInsomniac/Nginx-Fancyindex-Theme) for elegant, modern directory listings
- Lightbox support for seamless image and video previews
- On-the-fly Markdown (`.md`) rendering in-browser
- Optional HTTP Basic Authentication for access control
- Configurable SSL/TLS support via environment variables

---

## Key Features

- **Modern UI:** Stylish Fancyindex theme for intuitive directory browsing
- **Markdown Preview:** Instantly view `.md` files as HTML
- **Media Lightbox:** Enhanced image/video viewing experience
- **Secure Access:** Toggle HTTP Basic Auth with environment variables
- **Flexible SSL:** Easily enable or disable SSL/TLS
- **Optimized Core:** Powered by Tengine 3.1.0, a high-performance Nginx fork

---

## Configuration

### Environment Variables

| Variable        | Default | Description                              |
| --------------- | ------- | ---------------------------------------- |
| `HTTP_AUTH`     | `off`   | Enable HTTP Basic Auth (`on`/`off`)      |
| `HTTP_USERNAME` | `admin` | Username for HTTP Basic Auth             |
| `HTTP_PASSWD`   | `admin` | Password for HTTP Basic Auth             |
| `ENABLE_SSL`    | `on`    | Enable (`on`) or disable (`off`) SSL/TLS |

### Volumes

| Container Path | Description                                   | Required                               |
| -------------- | --------------------------------------------- | -------------------------------------- |
| `/app/public`  | Directory to serve files                      | Yes                                    |
| `/app/ssl`     | SSL certificates (`server.crt`, `server.key`) | Optional (required if `ENABLE_SSL=on`) |

### Ports

| Container Port | Protocol | Description |
| -------------- | -------- | ----------- |
| 80             | HTTP     | Plain HTTP  |
| 443            | HTTPS    | Secure HTTP |

---

## Quick Start

### 1. Build the Image

```bash
docker buildx create --name multiarch-builder --use
docker buildx build --no-cache \
  --platform linux/amd64,linux/arm64 .
#  -t docker.io/jas0n0ss/tengine-fancyindex:latest \
#  --push \
#  .
```

### 2. Prepare Content & SSL

- Place files to serve in `./public`
- For SSL, add `server.crt` and `server.key` to `./ssl`

Generate a self-signed certificate (for testing):

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ./ssl/server.key \
  -out ./ssl/server.crt \
  -subj "/CN=localhost"
```

### 3. Launch the Container

```bash
docker run -d \
  -p 8083:80 \
  -p 8084:443 \
  -e HTTP_AUTH="on" \
  -e HTTP_USERNAME="myuser" \
  -e HTTP_PASSWD="mypassword" \
  -e ENABLE_SSL="on" \
  -v $(pwd)/public:/app/public \
  -v $(pwd)/ssl:/app/ssl \
  --restart unless-stopped \
  tengine-fancyindex
```

- **Disable SSL:** `-e ENABLE_SSL="off"`
- **Disable Auth:** `-e HTTP_AUTH="off"` or omit

---

## Docker Compose Example

`docker-compose.yml`:

```yaml
version: '3.8'
services:
  tengine-fancy:
    build: .
    ports:
      - "8083:80"
      - "8084:443"
    environment:
      HTTP_AUTH: "on"
      HTTP_USERNAME: "admin"
      HTTP_PASSWD: "admin"
      ENABLE_SSL: "on"
    volumes:
      - ./public:/app/public
      - ./ssl:/app/ssl
    restart: unless-stopped
```

Start with:

```bash
docker-compose up -d
```

