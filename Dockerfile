# Base image for Ubuntu 20.04 (compatible with ROS Noetic and Galactic)
FROM osrf/ros:galactic-desktop

# Install dependencies for both ROS versions
RUN apt-get update && apt-get install -y \
    lsb-release \
    gnupg2 \
    curl \
    python3-pip \
    build-essential \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*

# Add ROS Noetic package source and keys
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros1-latest.list' && \
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

# Install ROS Noetic
RUN apt-get update && apt-get install -y \
    ros-noetic-desktop-full \
    && rm -rf /var/lib/apt/lists/*


# Set up environment for ROS 1 and ROS 2
SHELL ["/bin/bash", "-c"]
RUN echo "cd /home/ros2/ros2_ws/" >> ~/.bashrc
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
RUN echo "source /opt/ros/galactic/setup.bash" >> ~/.bashrc

# Install ros1_bridge dependencies
RUN apt-get update && apt-get install -y \
    python3-colcon-common-extensions \
    ros-galactic-ros1-bridge \
    && rm -rf /var/lib/apt/lists/*

# Clone the ros1_bridge repository
COPY ./src/ros1_bridge /home/ros2/ros2_ws/src/ros1_bridge

# Build the ros1_bridge
RUN cd  /home/ros2/ros2_ws/ && \
    source /opt/ros/noetic/setup.bash && \
    source /opt/ros/galactic/setup.bash && \
    colcon build --symlink-install --packages-select ros1_bridge

RUN echo "source install/setup.bash" >> ~/.bashrc
RUN echo "ros2 run ros1_bridge static_bridge " >> ~/.bashrc


# # Set up entrypoint
#COPY ./entrypoint.sh /
#RUN chmod +x /entrypoint.sh
#ENTRYPOINT ["/entrypoint.sh"]
