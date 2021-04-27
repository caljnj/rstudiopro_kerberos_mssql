#!/bin/bash


sudo podman build --no-cache \
  --tag=test:rstudiopro_s6 \
  --log-level=info\
  .

sudo podman image prune -f
