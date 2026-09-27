import numpy as np

def cart2sph(x,y,z):
    azimuth = np.arctan2(y,x)
    elevation = np.arctan2(z,np.sqrt(x**2 + y**2))
    r = np.sqrt(x**2 + y**2 + z**2)
    return azimuth, elevation

def sph2cart(azimuth,elevation,r):
    x = r * np.cos(elevation) * np.cos(azimuth)
    y = r * np.cos(elevation) * np.sin(azimuth)
    z = r * np.sin(elevation)
    return x, y, z

def Zenital_tilt(mat_azimuth_rad = None,mat_elevation_rad = None,rotation_axis_aziluth_rad = None,rotation_angle_rad = None): 
    # INPUTS :
# mat_azimuth_rad : radian
# mat_elevation_rad : radian
# rotation_axis_aziluth_rad : radian
# rotation_angle_rad : radian
    
    # OUTPUTS :
# tilted_mat_azimuth_rad : radian
# tilted_mat__elevation_rad : radian
    
    # MEANING :
# change visual field if camera optical axis is tilted from true vertical
    
    # - mat_azimuth_rad and mat_elevation_rad are the azimuth and elevation
# matrix of the visual field covered by sensor supposing it was looking
# toward vertical axis.
    
    # - rotation_axis_azimuth_rad is the azimuth of the axis the camera is tilted
# on, in the (x,y,z) horizontal plane.
# 'z' is true vertical (up), 'x' is oriented in sensor's width direction
# (supposing upposing it was looking toward  true vertical axis),'y' is
# oriented in sensor's high direction (supposing upposing it was looking
# toward true vertical axis).
    
    # - rotation_angle_rad is the rotation angle from true vertical
# to actual camera vertical, around the axis of azimuth
# rotation_axis_azimuth.
    
    # Rotation matrix in canonical frame :
    Rot_abup = np.array([[1,0,0],[0,np.cos(rotation_angle_rad),- np.sin(rotation_angle_rad)],[0,np.sin(rotation_angle_rad),np.cos(rotation_angle_rad)]])
    # transition matrix:
    Mat_abup_to_xyz = np.array([[np.cos(rotation_axis_aziluth_rad),- np.sin(rotation_axis_aziluth_rad),0],[np.sin(rotation_axis_aziluth_rad),np.cos(rotation_axis_aziluth_rad),0],[0,0,1]])
    # transition matrix
    Mat_xyz_to_abup = np.array([[np.cos(rotation_axis_aziluth_rad),np.sin(rotation_axis_aziluth_rad),0],[- np.sin(rotation_axis_aziluth_rad),np.cos(rotation_axis_aziluth_rad),0],[0,0,1]])
    # Rotation matrix in xyz frame :
    Rot_xyz = Mat_abup_to_xyz * Rot_abup * Mat_xyz_to_abup
    # Express field in cartesian coordinates:
    x = np.multiply(np.cos(mat_elevation_rad),np.cos(mat_azimuth_rad))
    y = np.multiply(np.cos(mat_elevation_rad),np.sin(mat_azimuth_rad))
    z = np.sin(mat_elevation_rad)
    # Rotate:
    x_prime = Rot_xyz[0,0] * x + Rot_xyz[0,1] * y + Rot_xyz[0,2] * z
    y_prime = Rot_xyz[1,0] * x + Rot_xyz[1,1] * y + Rot_xyz[1,2] * z
    z_prime = Rot_xyz[2,0] * x + Rot_xyz[2,1] * y + Rot_xyz[2,2] * z
    # Express new field in spherical coordinates :
    tilted_mat_azimuth_rad,tilted_mat__elevation_rad = cart2sph(x_prime,y_prime,z_prime)
    return tilted_mat_azimuth_rad,tilted_mat__elevation_rad
    