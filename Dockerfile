FROM osrf/ros:humble-desktop-full

# RUN pip3 install --upgrade numpy

# Example of installing programs
RUN apt-get update \
  && apt-get install -y \
  python3-pip \
  python3-setuptools \
  python3-dev \
  build-essential \
  cmake \
  curl \
  # git \
  python3-colcon-common-extensions \
  python3-vcstool \
  wget \
  # clang \
  # lldb \
  # lld \
  nano \
  apt-utils \
  ros-humble-sdformat-urdf \
  ros-humble-ros-gz-interfaces \
  ros-humble-xacro \
  ros-humble-navigation2 \
  ros-humble-nav2-bringup \
  ros-humble-robot-localization \
  ros-humble-slam-toolbox \
  ros-dev-tools \
  python-is-python3 \
  libgl1-mesa-glx \
  libegl1-mesa \
  libgles2-mesa \
  libx11-dev \
  libxi-dev \
  libxmu-dev \
  x11-utils \
  mesa-utils \
  libgl1-mesa-glx \
  libgl1-mesa-dri \
  libx11-xcb1 \
  libxcb-glx0 \
  python3-shapely \
  python3-yaml \
  python3-requests \
  net-tools \
  # clang \
  # clang-tools \
  # libstdc++-12-dev \
  && rm -rf /var/lib/apt/lists/* 


RUN pip install \
  flask==3.1.0 \
  fastapi==0.115.12 \
  uvicorn==0.34.2 \
  flask-cors==5.0.1 \
  websockets==9.1 \
  # flask-socketio==5.3.4 \
  python-socketio==5.13.0

# ignition gazebo

RUN wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
RUN apt-get update
RUN apt-get install lsb-release wget gnupg
RUN apt-get -y install ignition-fortress
RUN apt -y install ros-humble-ros-gz
RUN apt update && apt install python3-colcon-common-extensions -y 

# rmf

RUN apt update && apt install ros-dev-tools -y
RUN rm -f /etc/ros/rosdep/sources.list.d/20-default.list && \
    rosdep init
RUN rosdep update
RUN if ! colcon mixin list | grep -q 'default'; then \
    colcon mixin add default https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml; \
    fi
RUN colcon mixin update default
RUN apt-get -y update && apt-get -y install ros-humble-rmf-dev


# RUN apt -y install ros-humble-rmw-cyclonedds-cpp

    
    
WORKDIR /workspaces
    
ENV XDG_RUNTIME_DIR=/tmp/runtime-root
RUN mkdir -p /tmp/runtime-root && chmod 700 /tmp/runtime-root
# ENV CC=clang
# ENV CXX=clang++
    
    
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
    
RUN echo "source /workspaces/rmf_ws/install/setup.bash" >> ~/.bashrc
    
RUN echo "source /workspaces/rmf_demo/install/setup.bash" >> ~/.bashrc

# RUN echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp" >> ~/.bashrc
    
    
SHELL ["/bin/bash","-c"]
    
# Command to run when starting the container
CMD /bin/bash