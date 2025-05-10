FROM osrf/ros:humble-desktop-full
RUN apt-get update && apt-get install -y python3-pip python3-setuptools python3-dev build-essential
RUN pip3 install --upgrade numpy
RUN apt-get update \
  && apt-get install -y \
  python3-pip \
  python3-setuptools \
  python3-dev \
  build-essential \
  cmake \
  curl \
  git \
  python3-colcon-common-extensions \
  python3-vcstool \
  wget \
  clang \
  lldb \
  lld \
  nano \
  apt-utils \
  ros-humble-sdformat-urdf \
  ros-humble-ros-gz-interfaces \
  ros-humble-hardware-interface \
  ros-humble-ros2-control \
  ros-humble-ros2-controllers \
  ros-humble-xacro \
  ros-humble-ign-ros2-control \
  ros-humble-navigation2 \
  ros-humble-nav2-bringup \
  ros-humble-robot-localization \
  ros-dev-tools \
  python-is-python3 \
  libgl1-mesa-glx \
  libegl1-mesa \
  libgles2-mesa \
  libx11-dev \
  libxi-dev \
  libxmu-dev \
  x11-utils \
  python3-shapely \
  python3-yaml \
  python3-requests \
  net-tools \
  && rm -rf /var/lib/apt/lists/* 

RUN apt update && apt install -y \
  wget gnupg software-properties-common apt-transport-https \
  libx11-xcb1 libxkbfile1 libsecret-1-0 libgtk-3-0 libasound2 \
  libnss3 libxss1 libgconf-2-4 libx11-dev libxkbfile-dev libxcomposite-dev

# Add Microsoft GPG key and repo
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
  install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ && \
  sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

# Install VS Code
RUN apt update && apt install -y code

RUN pip install \
  flask==3.1.0 \
  fastapi==0.115.12 \
  uvicorn==0.34.2 \
  flask-cors==5.0.1 \
  websockets==9.1 \
  # flask-socketio==5.3.4 \
  python-socketio==5.13.0


RUN wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
RUN apt-get update
RUN apt-get -y install ignition-fortress
RUN apt -y install ros-humble-ros-gz
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
RUN apt update && apt install python3-colcon-common-extensions -y
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D2486D2DD83DB69272AFE98867170598AF249743

# setup sources.list
#RMF
RUN rm -f /etc/ros/rosdep/sources.list.d/20-default.list && \
    rosdep init
RUN rosdep update
RUN if ! colcon mixin list | grep -q 'default'; then \
    colcon mixin add default https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml; \
    fi
RUN colcon mixin update default
RUN apt update && apt-get install -y \
    ros-humble-rmf-dev 
SHELL ["/bin/bash", "-c"]

CMD ["/bin/bash"]
