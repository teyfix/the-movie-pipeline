#!/usr/bin/env bash

# 1000 is bun user id in the container
mkdir -p /sample
chown -R "1000:1000" /sample

# Start generation script
su bun -c 'bash /app/generate.sh'
