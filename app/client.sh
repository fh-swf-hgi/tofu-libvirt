#!/usr/bin/env bash
# VirtLab Demo-Client
# Fragt den Server in festen Abstaenden ab und schreibt jede Antwort ins Journal
# (journalctl -u demo-client -f). Konfiguration in /etc/default/demo-client.
set -u

SERVER_URL="${SERVER_URL:-http://10.20.0.10:8080/}"
INTERVAL="${INTERVAL:-5}"

while true; do
  if reply=$(curl -fsS --max-time 3 "$SERVER_URL"); then
    echo "OK     $reply"
  else
    echo "FEHLER $SERVER_URL nicht erreichbar"
  fi
  sleep "$INTERVAL"
done
