import sys
if sys.prefix == '/usr':
    sys.real_prefix = sys.prefix
    sys.prefix = sys.exec_prefix = '/home/dream_hell/learning_rmf_ws/src/install/mr_robot_description'
