#!/usr/bin/env bash
# share-frontend.sh — expose a local dev server to the Tailnet.
#
# Two modes:
#   direct  (default, always works): print URLs to reach a dev server already
#           bound to 0.0.0.0:<port>. No tailnet admin setup required.
#   serve   (optional): use `tailscale serve` for HTTPS at port 443 with a
#           MagicDNS-backed cert. Requires the tailnet admin to have enabled
#           the Serve/HTTPS feature in https://login.tailscale.com/admin.
#
# Usage:
#   ./scripts/share-frontend.sh url <port>            # print direct URLs (default)
#   ./scripts/share-frontend.sh check <port>          # verify dev server is on 0.0.0.0
#   ./scripts/share-frontend.sh serve <port>          # tailscale serve HTTPS -> :port
#   ./scripts/share-frontend.sh serve <port> --http   # tailscale serve plain HTTP :80
#   ./scripts/share-frontend.sh serve-status
#   ./scripts/share-frontend.sh serve-stop

set -euo pipefail

require_tailscale() {
  if ! command -v tailscale >/dev/null 2>&1; then
    echo "error: tailscale CLI not found in PATH" >&2
    exit 1
  fi
  if ! tailscale status >/dev/null 2>&1; then
    echo "error: tailscaled not running or not logged in (run: sudo tailscale up)" >&2
    exit 1
  fi
}

get_dns_name() {
  tailscale status --json \
    | python3 -c 'import sys,json; n=json.load(sys.stdin)["Self"]["DNSName"]; print(n.rstrip("."))'
}

cmd_url() {
  local port="${1:-}"
  if [[ -z "$port" ]]; then
    echo "usage: $0 url <port>" >&2
    exit 2
  fi
  require_tailscale
  local name ip
  name="$(get_dns_name)"
  ip="$(tailscale ip -4)"
  echo "Direct-IP / MagicDNS URLs (dev server must bind 0.0.0.0:${port}):"
  echo "  http://${ip}:${port}/"
  echo "  http://${name}:${port}/"
}

cmd_check() {
  local port="${1:-}"
  if [[ -z "$port" ]]; then
    echo "usage: $0 check <port>" >&2
    exit 2
  fi
  if ! command -v ss >/dev/null 2>&1; then
    echo "ss not available; skip listen check" >&2
    return 0
  fi
  local line
  line="$(ss -tln "sport = :${port}" | tail -n +2)"
  if [[ -z "$line" ]]; then
    echo "FAIL  nothing listening on port ${port}"
    exit 1
  fi
  if echo "$line" | grep -qE '(^|[[:space:]])(0\.0\.0\.0|\*):'"${port}"'\b'; then
    echo "OK    listening on 0.0.0.0:${port} — reachable from Tailscale peers"
  elif echo "$line" | grep -qE '127\.0\.0\.1:'"${port}"'\b'; then
    echo "FAIL  bound to 127.0.0.1:${port} only — Tailscale peers cannot reach"
    echo "      Fix: restart dev server with --host 0.0.0.0 (see SHARING.md)"
    exit 1
  else
    echo "WARN  unexpected bind:"
    echo "      $line"
  fi
}

cmd_serve() {
  local port="${1:-}"
  local mode="${2:-}"
  if [[ -z "$port" ]]; then
    echo "usage: $0 serve <port> [--http]" >&2
    exit 2
  fi
  require_tailscale
  if [[ "$mode" == "--http" ]]; then
    tailscale serve --bg --http=80 "http://127.0.0.1:${port}"
  else
    tailscale serve --bg "http://127.0.0.1:${port}"
  fi
  echo
  echo "Sharing http://127.0.0.1:${port} via tailscale serve."
  tailscale serve status || true
}

cmd_serve_status() {
  require_tailscale
  tailscale serve status
}

cmd_serve_stop() {
  require_tailscale
  tailscale serve reset
  echo "tailscale serve config cleared."
}

cmd="${1:-help}"
case "$cmd" in
  url)          shift; cmd_url "$@" ;;
  check)        shift; cmd_check "$@" ;;
  serve)        shift; cmd_serve "$@" ;;
  serve-status) cmd_serve_status ;;
  serve-stop)   cmd_serve_stop ;;
  -h|--help|help)
    sed -n '2,20p' "$0"
    ;;
  *)
    echo "unknown command: $cmd" >&2
    sed -n '2,20p' "$0" >&2
    exit 2
    ;;
esac
