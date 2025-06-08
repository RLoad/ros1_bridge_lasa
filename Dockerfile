# Base image for Ubuntu 20.04 (compatible with ROS Noetic and Galactic)
FROM osrf/ros:galactic-desktop

SHELL ["/bin/bash", "-c"]

# 1. 删除 snapshots 源、添加 ROS 2 & ROS 1 官方仓库和公钥
RUN \
    # （改动）先删除过期的 snapshots.ros.org 仓库，避免签名校验失败     \
    sed -i '/snapshots.ros.org/d' /etc/apt/sources.list.d/*.list && \
    # 安装基础工具                                                     \
    apt-get update && apt-get install -y curl gnupg2 lsb-release && \
    # （改动）添加 ROS 2 官方 GPG 公钥并声明仓库                             \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
      | apt-key add - && \
    echo "deb [arch=amd64] http://packages.ros.org/ros2/ubuntu $(lsb_release -sc) main" \
      > /etc/apt/sources.list.d/ros2.list && \
    # （改动）添加 ROS 1 Noetic 官方 GPG 公钥并声明仓库                        \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc \
      | apt-key add - && \
    echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" \
      > /etc/apt/sources.list.d/ros1-latest.list && \
    rm -rf /var/lib/apt/lists/*

# 2. 安装所有依赖，包括 ROS Noetic、ros1_bridge 及构建工具
RUN apt-get update && apt-get install -y \
      lsb-release \
      curl \
      gnupg2 \
      python3-pip \
      build-essential \
      cmake \
      git \
      ros-noetic-desktop-full \
      python3-colcon-common-extensions \
      ros-galactic-ros1-bridge \
    && rm -rf /var/lib/apt/lists/*

# 3. 设置自动 source 环境
RUN echo "cd /home/ros2/ros2_ws/"               >> ~/.bashrc && \
    echo "source /opt/ros/noetic/setup.bash"   >> ~/.bashrc && \
    echo "source /opt/ros/galactic/setup.bash" >> ~/.bashrc

# 4. 拷贝并编译 ros1_bridge
COPY ./src/ros1_bridge /home/ros2/ros2_ws/src/ros1_bridge
RUN source /opt/ros/noetic/setup.bash && \
    source /opt/ros/galactic/setup.bash && \
    cd /home/ros2/ros2_ws/ && \
    colcon build --symlink-install --packages-select ros1_bridge

# 5. 构建后在 bashrc 中加入 bridge 的 setup 与启动命令
RUN echo "source /home/ros2/ros2_ws/install/setup.bash" >> ~/.bashrc && \
    echo "ros2 run ros1_bridge static_bridge"      >> ~/.bashrc

# （可选）entrypoint 脚本
# COPY ./entrypoint.sh /
# RUN chmod +x /entrypoint.sh
# ENTRYPOINT ["/entrypoint.sh"]
