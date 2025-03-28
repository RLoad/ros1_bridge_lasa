## planner
# terminal1
cd Worskpace/ros1_bridge_lasa/
docker load integrartion_rosbridge_epfl.tar
docker compose up -d
docker exec -it ros_bridge_container bash


It should automatically run the roslaunch but if zou interuppt you can run :
ros2 run ros1_bridge static_bridge


# T tell me
* just docker compose build
* then docker compose up
