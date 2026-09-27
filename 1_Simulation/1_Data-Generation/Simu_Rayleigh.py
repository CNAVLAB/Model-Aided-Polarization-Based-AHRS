import numpy as np
    
def Simu_Rayleigh(Sun_Elevation = None,Sun_Azimuth = None,Sky_Particule_Elevation_Matrix = None,Sky_Particule_Azimuth_Matrix = None,DoLP_Max = None): 
    # INPUTS :
#Sun_Elevation, Sun_Azimuth, Sky_Particule_Elevation_Matrix, and
#Sky_Particule_Azimuth_Matrix are all in radians.
# DoP_Max takes value between 0 and 1.
    
    #  OUTPUTS :
#AoP_Matrix_Global is the matrix of AoP_g in skydome that each pixel looks.
#DoP_Matrix is the matrix of DoP in skydome that each pixel looks.
    
    #MEANING :
#This function returns, for given sun position, field observed and maximum
#DoLP observable the polarization parameters, according to Rayleigh's model
    
    #Sun vector in XYZ coordinates
    Xsun = np.cos(Sun_Elevation) * np.cos(Sun_Azimuth)
    Ysun = np.cos(Sun_Elevation) * np.sin(Sun_Azimuth)
    Zsun = np.sin(Sun_Elevation)
    #Particule vectors in XYZ coordinates
    Xparticule = np.multiply(np.cos(Sky_Particule_Elevation_Matrix),np.cos(Sky_Particule_Azimuth_Matrix))
    Yparticule = np.multiply(np.cos(Sky_Particule_Elevation_Matrix),np.sin(Sky_Particule_Azimuth_Matrix))
    Zparticule = np.sin(Sky_Particule_Elevation_Matrix)
    #AoP_g Matrix :
    
    #the local AoP in 3D frame is the Angle between the E vector (OP x OS) and
#the plane which contains OP and Z.
    
    Tan_AoP_L = (np.multiply(np.sin(Sky_Particule_Elevation_Matrix) * np.cos(Sun_Elevation),np.cos(Sun_Azimuth - Sky_Particule_Azimuth_Matrix)) - np.sin(Sun_Elevation) * np.cos(Sky_Particule_Elevation_Matrix)) / (np.cos(Sun_Elevation) * np.sin(- Sun_Azimuth + Sky_Particule_Azimuth_Matrix))
    AoP_Matrix_Global = np.arctan(np.tan(np.arctan(Tan_AoP_L) + Sky_Particule_Azimuth_Matrix))
    #here we use "AoP_g=atan(tan (AoP_L - alpha_p))" to have AoP_g between -pi/2 and +pi/2
    
    #DoLP Array :
    
    cos_diffusion_angle = Xsun * Xparticule + Ysun * Yparticule + Zsun * Zparticule
    DoLP_Matrix = (1 - np.multiply(cos_diffusion_angle,cos_diffusion_angle)) / (1 + np.multiply(cos_diffusion_angle,cos_diffusion_angle))
    print(DoLP_Matrix.shape)
    DoLP_Matrix = np.maximum(0,np.minimum(DoLP_Max,1)) * DoLP_Matrix
    return AoP_Matrix_Global,DoLP_Matrix
    
    return AoP_Matrix_Global,DoLP_Matrix
