import numpy as np
    
def Simu_Optical_Conjugation(Sensor_Pixel_Size = None,Width_in_Pixels = None,Height_in_Pixels = None,Focal_Length = None,Conj_Type = None,Central_pixel_horizontal_switch = None,Central_pixel_vertical_switch = None): 
    # INPUTS :
#Focal_Length in milimeters
#Sensor_Pixel_Size in micro meter (square pixel)
#Central_pixel_XXX_switch are the horizontal and vertical coordinates of the
#optical axis on the sensor in pixels (left on the image: positive, up on
# the imge : positive)
    
    #  OUTPUTS :
#Incident_Rays_Azimuth_Matrix and Incident_Rays_Elevation_Matrix are in
#radian.
#X_coordinate_pixels and Y_coordinate_pixels are in pixels.
    
    #MEANING :
#This function returns, for a given sensor and optical conjugation, 4 matrix
#sensor sized, up left in each matrix correspond to up left in the image
#retured in the sensor.
#Incident_Rays_Azimuth_Matrix and Incident_Rays_Elevation_Matrix are the
#matrix of azimuth and elevation each pixel sees in skydome.
#X_coordinate_pixels and Y_coordinate_pixels are two array respectively
#row-size and column-size which give the coordinate of pixel (i,j) in xyz
#frame:
#x=X_coordinate_pixels(j) y=Y_coordinate_pixels(i)
#z is up. x and y are in horizontal plane, x in image lenght, y in image high
    
    #Conj_Type possible valueS
#       r0 : perspective imaging -> thin lens model
#       r1 : stereographic imaging
#       r2 : equidistance imaging -> twice the incident angle, twice the
#       image length
#       r3 : equi-solid angle imaging -> twice the incident solid angle, twice the image area
#       r4 : vertical imaging
#see references in "Digital deformation model for fisheye image
#rectification" By Wenguang Hou, Mingyue Ding, Nannan Qin and Xudong Lai
    
    #put focal length in micrometers
    Focal_Length = Focal_Length * 1000
    #pixels coordinates in pixels
    X_coordinate_pixels = np.linspace((Width_in_Pixels - 1) / 2,- (Width_in_Pixels - 1) / 2,Width_in_Pixels) - Central_pixel_horizontal_switch
    Y_coordinate_pixels = np.linspace((Height_in_Pixels - 1) / 2,- (Height_in_Pixels - 1) / 2,Height_in_Pixels) - Central_pixel_vertical_switch
    #pixels coordianates in micrometers:
    X_coordinate_microm = Sensor_Pixel_Size * X_coordinate_pixels
    Y_coordinate_microm = Sensor_Pixel_Size * Y_coordinate_pixels
    Complex_Sensor_Plane = np.ones((Height_in_Pixels,1)) * X_coordinate_microm + 1j * (np.transpose(Y_coordinate_microm)[:,np.newaxis]) * np.ones((1,Width_in_Pixels))
    Incident_Rays_Azimuth_Matrix = np.angle(Complex_Sensor_Plane)
    if Conj_Type == 'r0':
        Incident_Rays_Elevation_Matrix = (np.pi / 2) - np.arctan(np.abs(Complex_Sensor_Plane) / Focal_Length)
    
    if Conj_Type == 'r1':
        Incident_Rays_Elevation_Matrix = (np.pi / 2) - 2 * np.arctan(np.abs(Complex_Sensor_Plane) / Focal_Length / 2)
    
    if Conj_Type == 'r2':
        Incident_Rays_Elevation_Matrix = (np.pi / 2) - (np.abs(Complex_Sensor_Plane) / Focal_Length)
    
    if Conj_Type == 'r3':
        Incident_Rays_Elevation_Matrix = (np.pi / 2) - 2 * np.arcsin(np.abs(Complex_Sensor_Plane) / Focal_Length / 2)
    
    if Conj_Type == 'r4':
        Incident_Rays_Elevation_Matrix = (np.pi / 2) - np.arcsin(np.abs(Complex_Sensor_Plane) / Focal_Length)
    
    return Incident_Rays_Azimuth_Matrix,Incident_Rays_Elevation_Matrix,X_coordinate_pixels,Y_coordinate_pixels
    