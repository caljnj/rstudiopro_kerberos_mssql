#!/bin/bash


sudo podman build --no-cache \
  --tag=test:rstudiopro_mappeddrives_test \
  --log-level=debug \
  .

sudo podman image prune -f