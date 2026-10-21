# syntax=docker/dockerfile:1
FROM python:3.12-slim-trixie AS build
RUN apt-get update \
 && apt-get install -y --no-install-recommends gcc libc6-dev patchelf \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /src
COPY requirements.txt .
RUN pip install --no-cache-dir nuitka==4.3.1 -r requirements.txt
COPY main.py .
COPY util ./util
RUN python -m nuitka --mode=onefile --python-flag=unbuffered --assume-yes-for-downloads \
      --output-dir=/out --output-filename=mimotion main.py

FROM debian:trixie-slim
RUN apt-get update \
 && apt-get install -y --no-install-recommends tzdata \
 && rm -rf /var/lib/apt/lists/*
ADD --chmod=755 --checksum=sha256:d2d7c97fbfefc763d5bbcbbb3f8d61f9dd3410ce5d05a737c414994b80b8cdd0 \
    https://github.com/aptible/supercronic/releases/download/v0.2.50/supercronic-linux-amd64 /usr/local/bin/supercronic
COPY --from=build /out/mimotion /app/mimotion
COPY --chmod=755 docker/entrypoint.sh /app/entrypoint.sh
ENV TZ=Asia/Shanghai CRON="23 18,20,22 * * *"
WORKDIR /data
VOLUME /data
ENTRYPOINT ["/app/entrypoint.sh"]
