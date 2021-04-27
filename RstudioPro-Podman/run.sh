#!/bin/bash

sudo podman run --privileged -dit \
    --name=rstudiopro_s6 \
    --mount 'type=volume,src=vol_rstudio_user_home1,dst=/home' \
    -p 8789:8787 \
    test:rstudiopro_s6
