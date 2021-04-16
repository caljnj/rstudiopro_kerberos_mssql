#!/bin/bash

sudo podman run --privileged -dit \
    --name=rstudiopro_mappeddrives_test \
    --mount 'type=volume,src=vol_rstudio_user_home1,dst=/home' \
    -p 8785:8787 \
    test:rstudiopro_mappeddrives_test