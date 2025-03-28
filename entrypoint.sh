#!/bin/bash
set -e

# Source ROS 1 and ROS 2 setups
#source /opt/ros/noetic/setup.bash
#source /opt/ros/galactic/setup.bash
#source /install/setup.bash
#ros2 run ros1_bridge static_bridge 

# Execute the passed command
exec "$@"
