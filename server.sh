#!/usr/bin/env bash

set -euo pipefail

main() {
    local ipaddr="$(ifconfig | grep 'broadcast' | awk '{print $2}')"
    [[ -n "$ipaddr" ]] && hugo server "$@" --bind "$ipaddr" --baseURL "http://$ipaddr"
}

main
