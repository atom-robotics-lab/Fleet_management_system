#!/bin/bash

# Allow local Docker containers to access the X server
xhost +local:

# Run the Docker container with RMF workspace and GUI support
docker run -it \
  --name rmf_ws \
  --net=host \
  -e DISPLAY=$DISPLAY \
  -e XDG_RUNTIME_DIR=/tmp/runtime-root \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /dev/dri:/dev/dri \
  -v $(pwd)/rmf_ws:/workspaces/rmf_ws \
  -v $(pwd)/rmf_demo:/workspaces/rmf_demo \
  rmf_image

#docker image build -t rmf_image .

