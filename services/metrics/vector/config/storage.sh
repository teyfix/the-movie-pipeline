#!/usr/bin/env sh
: "${STORAGE_NAME:?Required environment variable STORAGE_NAME not set}"
: "${STORAGE_PATH:?Required environment variable STORAGE_PATH not set}"

if total_bytes="$(du -sb "${STORAGE_PATH}" 2> /dev/null | awk '{print $1}')"; then
  status="available"
else
  status="unavailable"
  total_bytes=0
fi

printf '{"status": "%s", "name": "%s", "path": "%s", "total_bytes": %s}' \
  "${status}" "${STORAGE_NAME}" "${STORAGE_PATH}" "${total_bytes}"
