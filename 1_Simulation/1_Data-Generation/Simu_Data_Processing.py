import numpy as np
    
def Simu_Data_Processing(Intensity_Matrix = None): 
    #  INPUTS :
#Intensity_Matrix : grayscale camera image
    
    #  OUTPUTS :
# AoP_data_processing_imframe : radian
# AoP_data_processing_meridianframe : radian
# DoLP_data_processing : no unit, positive value, can exceed 1.
    
    #  MEANING :
#This function is not a real part of the simulator. It is just about to see
# polarization parameters the simpliest way.
    
    #This function returns :
# - the angle of polarizarition according to image frame
#(AoP_data_processing_camframe). 0 rad for polarization along horizontal
#axis
# - the angle of polarizarition according to local meridian frame
#(AoP_data_processing_meridianframe). 0 rad for polarization along the
# meridian axis (axis from the center of the image to the pixel)
# - the degree of linear polarization (DoLP_data_processing)
    
    # The sensor used for data processing is based on sony IMX250MZR sensor of
# FLIR BFS-U3-51S5P-C camera.
# It is a sensor with a micro-polarizer array, each block of 2 by 2 pixels
# possess 4 type of linear micro-polarizer oriented at 0,45,90 and 135 degree
    
    #The pattern of micro-polarizer array in the returned image direct frame
#is:
#   90  45
#   135 0
# It can aslo be seen as :
#   |  /
#   \  -
    
    rows,cols = Intensity_Matrix.shape
    rows_final_image = int(rows / 2)
    cols_final_image = int(cols / 2)
    #Make output matrix, half the high and half the width of input matrix :
    AoP_data_processing_imframe = np.zeros((rows_final_image,cols_final_image))
    AoP_data_processing_meridianframe = np.zeros((rows_final_image,cols_final_image))
    DoLP_data_processing = np.zeros((rows_final_image,cols_final_image))
    for k in (range(rows_final_image)):
        for j in (range(cols_final_image)):
            #Compute Stokes parameters :
            S0 = 0.5 * (Intensity_Matrix[2 * k ,2 * j ] + Intensity_Matrix[2 * k ,2 * j +1] + Intensity_Matrix[2 * k+1,2 * j] + Intensity_Matrix[2 * k+1,2 * j+1])
            S1 = Intensity_Matrix[2 * k+1,2 * j+1] - Intensity_Matrix[2 * k ,2 * j ]
            S2 = Intensity_Matrix[2 * k ,2 * j+1] - Intensity_Matrix[2 * k+1,2 * j ]
            DoLP_data_processing[k,j] = np.sqrt((S1 ** 2) + (S2 ** 2)) / S0
            AoP_data_processing_imframe[k,j] = 0.5 * np.arctan2(S2,S1)
            #Compute pixels' coordinates:
            x_super_pixel = + j - (cols_final_image / 2) - 0.5
            y_super_pixel = - k + (rows_final_image / 2) + 0.5
            AoP_data_processing_meridianframe[k,j] = 0.5 * np.angle((S1 + S2 * 1j) / (x_super_pixel + y_super_pixel * 1j) / (x_super_pixel + y_super_pixel * 1j))
    
    return AoP_data_processing_imframe,AoP_data_processing_meridianframe,DoLP_data_processing

