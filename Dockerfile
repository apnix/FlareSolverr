FROM ubuntu:22.04

# Install dependencies and create flaresolverr user
# You can test Chromium running this command inside the container:
#    xvfb-run -s "-screen 0 1600x1200x24" chromium --no-sandbox
# The error traces is like this: "*** stack smashing detected ***: terminated"
# To check the package versions available you can use this command:
#    apt-cache madison chromium

WORKDIR /app/flaresolverr

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Moscow

# Install packages
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:saiarcot895/chromium-beta && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    chromium-browser=1:108.0.5359.40-0ubuntu1~ppa1~22.04.1 \
    xvfb \
    python3-pip \
    xvfb x11vnc fluxbox dumb-init wget mc nano \
    supervisor \
    && \
    # Remove temporary files and hardware decoding libraries
    rm -rf /var/lib/apt/lists/* && \
    rm -f /usr/lib/x86_64-linux-gnu/libmfxhw* && \
    rm -rf /root/.cache

# Install Python dependencies
COPY requirements.txt .

RUN pip install -r requirements.txt && \
    # Remove temporary files
    find / -name '*.pyc' -delete

# Create flaresolverr user
RUN useradd --home-dir /app --shell /bin/sh flaresolverr && \
    chown -R flaresolverr:flaresolverr /app && \
    mkdir /app/screenshots && \
    chown -R flaresolverr:flaresolverr /app/screenshots && \
    usermod -u 1001 flaresolverr

RUN mkdir /opt/run && chown flaresolverr:flaresolverr /opt/run && chown flaresolverr:flaresolverr /var/log/supervisor

USER flaresolverr

RUN mkdir -p /app/Downloads && mkdir -p /app/ChromeProfile

COPY package.json ../

EXPOSE 8191
EXPOSE 8192

# dumb-init avoids zombie chromium processes
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/usr/local/bin/python", "-u", "/app/flaresolverr.py"]

# Local build
# docker build -t ngosang/flaresolverr:3.3.2 .
# docker run -p 8191:8191 ngosang/flaresolverr:3.3.2

# Multi-arch build
# docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
# docker buildx create --use
# docker buildx build -t ngosang/flaresolverr:3.3.2 --platform linux/386,linux/amd64,linux/arm/v7,linux/arm64/v8 .
#   add --push to publish in DockerHub

# Test multi-arch build
# docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
# docker buildx create --use
# docker buildx build -t ngosang/flaresolverr:3.3.2 --platform linux/arm/v7 --load .
# docker run -p 8191:8191 --platform linux/arm/v7 ngosang/flaresolverr:3.3.2

CMD ["/usr/bin/python3", "-u", "/app/flaresolverr.py"]

ENTRYPOINT ["/app/flaresolverr/entrypoint.sh"]
