#!/usr/bin/env python3
from launch import LaunchDescription
from launch_ros.actions import Node
from launch.actions import IncludeLaunchDescription
from ament_index_python.packages import get_package_share_directory
from launch.substitutions import Command
from launch_ros.descriptions import ParameterValue
from launch.launch_description_sources import PythonLaunchDescriptionSource

def generate_launch_description():
    xacro_file = get_package_share_directory('mr_robot_description') + '/urdf/mr_robot.xacro'
    bridge_config = get_package_share_directory('mr_robot_gazebo') + '/config/bridge.yaml'
    world_path = get_package_share_directory("mr_robot_gazebo") + "/worlds/rmf.world"

    # Robot description for tinyBot_1
    robot_description_1 = ParameterValue(
        Command(['xacro ', xacro_file, ' sim_ign:=true robot_name:=tinyBot_1']),
        value_type=str
    )

    # Robot description for tinyBot_2
    robot_description_2 = ParameterValue(
        Command(['xacro ', xacro_file, ' sim_ign:=true robot_name:=tinyBot_2']),
        value_type=str
    )

    # Robot State Publisher for tinyBot_1
    rsp_robot1 = Node(
        package='robot_state_publisher',
        executable='robot_state_publisher',
        name='robot_state_publisher',
        namespace='tinyBot_1',
        parameters=[{'robot_description': robot_description_1}, {'use_sim_time': True}],
        remappings=[('robot_description', '/tinyBot_1/robot_description')]
    )

    # Robot State Publisher for tinyBot_2
    rsp_robot2 = Node(
        package='robot_state_publisher',
        executable='robot_state_publisher',
        name='robot_state_publisher',
        namespace='tinyBot_2',
        parameters=[{'robot_description': robot_description_2}, {'use_sim_time': True}],
        remappings=[('robot_description', '/tinyBot_2/robot_description')]
    )

    # Spawn robot 1
    spawn_robot1 = Node(
        package='ros_gz_sim',
        executable='create',
        output='screen',
        arguments=[
            '-name', 'tinyBot_1',
            '-topic', '/tinyBot_1/robot_description',
            '-allow_renaming', 'true',
            '-x', '1.4636949791993532', '-y', '-1.4226328173048066', '-z', '0.0',
            '-Y', '0.006154786001831508'
        ],
        parameters=[{'use_sim_time': True}]
    )

    # Spawn robot 2
    spawn_robot2 = Node(
        package='ros_gz_sim',
        executable='create',
        output='screen',
        arguments=[
            '-name', 'tinyBot_2',
            '-topic', '/tinyBot_2/robot_description',
            '-allow_renaming', 'true',
            '-x', '18.978043686139245', '-y', '-2.2643002034297415', '-z', '0.0',
            '-Y', '0.003175104013493772'
        ],
        parameters=[{'use_sim_time': True}]
    )

    # Gazebo simulator
    gazebo = IncludeLaunchDescription(
        PythonLaunchDescriptionSource([
            get_package_share_directory('ros_gz_sim'), '/launch/gz_sim.launch.py'
        ]),
        launch_arguments={
            'gz_args': [world_path],
            'on_exit_shutdown': 'true'
        }.items()
    )

    # ROS-Gz bridge
    ros_gz_bridge = Node(
        package="ros_gz_bridge",
        executable="parameter_bridge",
        parameters=[{'config_file': bridge_config}],
        output='screen'
    )

    return LaunchDescription([
        gazebo,
        ros_gz_bridge,
        rsp_robot1,
        rsp_robot2,
        spawn_robot1,
        spawn_robot2,
    ])