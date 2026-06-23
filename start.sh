#!/bin/bash
set -e

# Fix ownership: the /opt/hermes/bin/hermes shim drops root to uid 10000
# (hermes user). Volume-mounted data originally created as uid 1024 becomes
# inaccessible. Chown once at boot so every subsequent access is uid-aligned.
if [ "$(id -u)" = "0" ]; then
    chown -R 10000:10000 /data 2>/dev/null || true
fi

# Mirror dashboard-ref-only startup: create every directory hermes expects
# and seed a default config.yaml if the volume is empty.
mkdir -p /data/.hermes/cron /data/.hermes/sessions /data/.hermes/logs \
         /data/.hermes/memories /data/.hermes/skills /data/.hermes/pairing \
         /data/.hermes/hooks /data/.hermes/image_cache /data/.hermes/audio_cache \
         /data/.hermes/workspace

if [ ! -f /data/.hermes/config.yaml ] && [ -f /opt/hermes-agent/cli-config.yaml.example ]; then
  cp /opt/hermes-agent/cli-config.yaml.example /data/.hermes/config.yaml
fi

[ ! -f /data/.hermes/.env ] && touch /data/.hermes/.env

exec python /app/server.py
