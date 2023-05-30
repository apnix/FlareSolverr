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
    chown -R flaresolverr:flaresolverr . && \
    mkdir /screenshots && \
    chown -R flaresolverr:flaresolverr /screenshots && \
    usermod -u 1001 flaresolverr

USER flaresolverr

COPY package.json ../

EXPOSE 8191

ENTRYPOINT ["/app/flaresolverr/entrypoint.sh"]