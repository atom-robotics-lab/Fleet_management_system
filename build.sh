#!/bin/bash

# Map host's display socket to docker
DOCKER_ARGS+=("-v /tmp/.X11-unix:/tmp/.X11-unix")
DOCKER_ARGS+=("-v $HOME/.Xauthority:/home/admin/.Xauthority:rw")
DOCKER_ARGS+=("-e DISPLAY")
DOCKER_ARGS+=("-e NVIDIA_VISIBLE_DEVICES=all")
DOCKER_ARGS+=("-e NVIDIA_DRIVER_CAPABILITIES=all")
DOCKER_ARGS+=("-e LIBGL_ALWAYS_INDIRECT=1")
DOCKER_ARGS+=("-e LIBGL_ALWAYS_SOFTWARE=1")
DOCKER_ARGS+=("-e MESA_LOADER_DRIVER_OVERRIDE=iris")
DOCKER_ARGS+=("--device /dev/dri:/dev/dri")

gpu=$(lspci | grep -i '.* vga .* nvidia .*')

xhost +local:root

image_name="fms_image"
container_name="fms_atom"

force_option=false 
clean_option=false

# Parse options
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      force_option=true
      shift
      ;;
    --clean)
      clean_option=true
      shift
      ;;
    *)
      echo "Invalid option: $1"
      exit 1
      ;;
  esac
done

if $force_option; then
  echo "Building Docker Image: $image_name"
  docker build -f Dockerfile -t "$image_name":1.0 .
else
  run_command='source /opt/ros/humble/setup.bash && colcon build --symlink-install && source install/setup.bash && exit'
  if $clean_option; then
    run_command='source /opt/ros/humble/setup.bash && rm -rf build log install && colcon build --symlink-install && source install/setup.bash && exit'
    echo "Clean build enabled"
  else
    echo "Normal build (no clean)"
  fi

  if docker images --format '{{.Repository}}' | grep -q "$image_name"; then
    echo "Found Docker Image: $image_name:1.0"

    if [[ $gpu == *'NVIDIA'* ]]; then
      printf 'Nvidia GPU detected: %s\n' "$gpu"
      docker run -it --rm \
          ${DOCKER_ARGS[@]} \
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
          "$image_name":1.0 \
          bash -c "$run_command"
    else
      printf 'Nvidia GPU not found\n'
      docker run -it --rm \
          ${DOCKER_ARGS[@]} \
          -v $PWD/build_files:/workspaces/rmf_ws/ \
          -v $PWD:/workspaces/rmf_ws/src \
          -v /var/run/docker.sock:/var/run/docker.sock \
          --name "$container_name" \
          --workdir /workspaces/rmf_ws \
          -v $PWD/ddsconfig.xml:/ddsconfig.xml \
          --env CYCLONEDDS_URI=/ddsconfig.xml \
          --network host \
          $@ \
          "$image_name":1.0 \
          bash -c "$run_command"
    fi
  else
    echo "Building new Docker image: $image_name"
    docker build -f Dockerfile -t "$image_name":1.0 .
    ./build.sh
  fi
fi
