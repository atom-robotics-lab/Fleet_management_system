#!/bin/bash

DOCKER_ARGS+=("-e NVIDIA_VISIBLE_DEVICES=all")
DOCKER_ARGS+=("-e NVIDIA_DRIVER_CAPABILITIES=all")
DOCKER_ARGS+=("-e LIBGL_ALWAYS_INDIRECT=1")
DOCKER_ARGS+=("-e LIBGL_ALWAYS_SOFTWARE=1")
DOCKER_ARGS+=("-e MESA_LOADER_DRIVER_OVERRIDE=iris")  # or "i965" or "softpipe"

gpu=$(lspci | grep -i '.* vga .* nvidia .*')

xhost +local:root

container_name="fms_atom"
image_name="fms_image"

if docker ps --format '{{.Names}}' | grep -q "$container_name"; then
    docker exec -it fms_atom /bin/bash
else
    if [[ $gpu == *'NVIDIA'* ]]; then
    printf 'Nvidia GPU is present:  %s\n' "$gpu"
    docker run -it --rm \
        ${DOCKER_ARGS[@]} \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v $HOME/.Xauthority:/home/admin/.Xauthority:rw \
        --device /dev/dri:/dev/dri \
        -v $PWD/build_files:/workspaces/rmf_ws/ \
        -v $PWD:/workspaces/rmf_ws/src \
        -v /var/run/docker.sock:/var/run/docker.sock \
        --name "$container_name" \
        --workdir /workspaces/rmf_ws \
        -v $PWD/ddsconfig.xml:/ddsconfig.xml \
        --env CYCLONEDDS_URI=/ddsconfig.xml \
        --runtime nvidia \
        --network host \
        $@ \
        "$image_name":1.0 
    else
    printf 'Nvidia GPU is not present: %s\n' "$gpu"
    docker run -it --rm \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v $HOME/.Xauthority:/home/admin/.Xauthority:rw \
        --device /dev/dri:/dev/dri \
        -v $PWD/build_files:/workspaces/rmf_ws/ \
        -v $PWD:/workspaces/rmf_ws/src \
        -v /var/run/docker.sock:/var/run/docker.sock \
        --name "$container_name" \
        --workdir /workspaces/rmf_ws \
        -v $PWD/ddsconfig.xml:/ddsconfig.xml \
        --env CYCLONEDDS_URI=/ddsconfig.xml \
        --network host \
        $@ \
        "$image_name":1.0 
    fi
fi
