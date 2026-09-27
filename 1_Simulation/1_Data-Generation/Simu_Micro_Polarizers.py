import numpy as np
    
def Simu_Micro_Polarizers(Sky_radiance = None,AoP_Matrix_Global_rad = None,DoLP_Matrix = None,tolerance_rad = None,extinction_ratio = None): 
    #  INPUTS :
#Sky_radiance : no unit because it is a relative energetic radiance
#AoP_Matrix_Global_rad : in radian
#DoP_Matrix : no unit, takes value between 0 and 1
#tolerance_rad : radian
#extinction_ratio : no unit, takes value between 0 and 1
    
    # If T1 is the intensity transmitance for an incident ray totaly linearly
# polarized along transmission axis and T2 is the intensity transmittance
# for an incident ray totally linearly polarized at 90 degrees from
# transmission axis, then the extinction rassio is (T1-T2)/(T1+T2).
# Because we work with relative intensity their is no need to take into
# account absorbance, so we suppose null absorbance, which means T1+T2=1.
    
    #  OUTPUTS :
#Intensity_on_pixels_Matrix : no unit because it is a relative energetic
#radiance
    
    #  MEANING :
#This function returns relative light energetic radiance after passing
#through micri-polarizers' array.
    
    #The sensor is based on sony IMX250MZR sensor of FLIR BFS-U3-51S5P-C camera.
#It is a sensor with a micro-polarizer array, each block of 2 by 2 pixels
# possess 4 types of linear micro-polarizer oriented at 0,45,90 and 135 degree
    
    #The pattern of micro-polarizer array in the returned image direct frame
#is:
#   90  45
#   135 0
# It can aslo be seen as :
#   |  /
#   \  -
#So, express in our x,y,z frame (z vertical axis pointing to zenith,
# x is left in the image, y is up in the image) :
#   90  135
#   45 0
# It can aslo be seen as :
#   |  \
#   /  -
    
    #create micro-polarizer directions matrix
    rows,cols = DoLP_Matrix.shape
    #Matrix of sensor size with only written the 135deg polarizers :
    Mat135 = np.abs((((3 * np.pi / 4) * np.sin(np.pi / 2 * (np.arange(1,rows+1,1)))))[:,np.newaxis] * np.cos(np.pi / 2 * (np.arange(1,cols+1,1)))[np.newaxis,:])
    #Matrix of sensor size with only written the 90deg polarizers :
    Mat90 = np.abs((((np.pi / 2) * np.sin(np.pi / 2 * (np.arange(1,rows+1,1)))))[:,np.newaxis] * np.sin(np.pi / 2 * (np.arange(1,cols+1,1)))[np.newaxis,:])
    #Matrix of sensor size with only written the 45deg polarizers :
    Mat45 = np.abs((((np.pi / 4) * np.cos(np.pi / 2 * (np.arange(1,rows+1,1)))))[:,np.newaxis] * np.sin(np.pi / 2 * (np.arange(1,cols+1,1)))[np.newaxis,:])
    #Matrix of sensor size with angular defects in polarizers' direction
    defects_matrix = tolerance_rad * (1 - 2 * np.random.rand(DoLP_Matrix.shape[0],DoLP_Matrix.shape[1]))
    #Matrix of sensor size with micro-polarizer directions
    Mat_polarizer_angle = Mat90 + Mat45 + Mat135 + defects_matrix
    Intensity_on_pixels_Matrix = np.multiply(0.5 * Sky_radiance,(1 + np.multiply(extinction_ratio * DoLP_Matrix,np.cos(2 * (AoP_Matrix_Global_rad - Mat_polarizer_angle)))))
    return Intensity_on_pixels_Matrix
    
    return Intensity_on_pixels_Matrix
