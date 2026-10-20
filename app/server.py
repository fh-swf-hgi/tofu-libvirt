#!/usr/bin/env python3
"""VirtLab Demo-Server.

Beantwortet jede HTTP-Anfrage mit einer JSON-Zeile: Hostname des Servers,
Adresse des Clients, laufende Nummer der Anfrage und Uhrzeit.
Der Zaehler liegt nur im Arbeitsspeicher und beginnt nach einem Neustart
wieder bei 1.
"""
import json
import os
import socket
import threading
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

PORT = int(os.environ.get("APP_PORT", "8080"))
HOSTNAME = socket.gethostname()

_lock = threading.Lock()
_count = 0


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        global _count
        if self.path == "/health":
            self._send({"status": "ok"})
            return
        with _lock:
            _count += 1
            number = _count
        self._send({
            "server": HOSTNAME,
            "client": self.client_address[0],
            "request": number,
            "time": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        })

    def _send(self, payload):
        body = (json.dumps(payload) + "\n").encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        # Zugriffe ins Journal schreiben (journalctl -u demo-server)
        print(f"{self.client_address[0]} {fmt % args}", flush=True)


if __name__ == "__main__":
    print(f"Demo-Server {HOSTNAME} lauscht auf Port {PORT}", flush=True)
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
