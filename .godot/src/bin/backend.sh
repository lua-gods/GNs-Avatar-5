#!/bin/sh
printf '\033c\033]0;%s\a' GN Avatar Backend
base_path="$(dirname "$(realpath "$0")")"
"$base_path/backend.x86_64" "$@"
