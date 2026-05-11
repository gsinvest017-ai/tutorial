#!/usr/bin/env bash
# share-frontend.sh — expose a local dev server to the Tailnet via `tailscale serve`.
#
# Usage:
#   ./scripts/share-frontend.sh start <port>   # HTTPS reverse-proxy to localhost:<port>
#   ./scripts/share-frontend.sh start <port> --http   # plain HTTP on :80 instead of HTTPS
#   ./scripts/share-frontend.sh status
#   ./scripts/share-frontend.sh stop
#   ./scripts/share-frontend.sh url            # print the public Tailnet URL
#
# Requires: tailscale CLI, running tailscaled, MagicDNS enabled in the tailnet.
# Notes:
#   - HTTPS mode needs "HTTPS certificates" toggled on in the tailnet admin console.
#   - Dev server must bind 0.0.0.0 (or 127.0.0.1 also works for serve — serve runs
#     on the same host and proxies through Tailscale).

set -euo pipefail

cmd="${1:-}"

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

cmd_start() {
  local port="${1:-}"
  local mode="${2:-}"
  if [[ -z "$port" ]]; then
    echo "usage: $0 start <port> [--http]" >&2
    exit 2
  fi
  require_tailscale

  if [[ "$mode" == "--http" ]]; then
    # Plain HTTP on tailnet port 80. No cert needed.
    tailscale serve --bg --http=80 "http://127.0.0.1:${port}"
  else
    # Default: HTTPS on 443 with auto-provisioned LE cert.
    tailscale serve --bg "http://127.0.0.1:${port}"
  fi

  echo
  echo "Sharing http://127.0.0.1:${port} on the tailnet."
  cmd_url
}

cmd_status() {
  require_tailscale
  tailscale serve status
}

cmd_stop() {
  require_tailscale
  # `serve reset` clears all serve config for this node.
  tailscale serve reset
  echo "All serve config cleared."
}

cmd_url() {
  require_tailscale
  local name
  name="$(get_dns_name)"
  echo "  HTTPS:  https://${name}/"
  echo "  HTTP :  http://${name}/   (only if started with --http)"
  echo "  Tailscale IP fallback: http://$(tailscale ip -4)/  (port depends on mode)"
}

case "$cmd" in
  start)  shift; cmd_start "$@" ;;
  status) cmd_status ;;
  stop)   cmd_stop ;;
  url)    cmd_url ;;
  ""|-h|--help|help)
    sed -n '2,15p' "$0"
    ;;
  *)
    echo "unknown command: $cmd" >&2
    sed -n '2,15p' "$0" >&2
    exit 2
    ;;
esac
