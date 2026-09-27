import numpy as np
    
def Simu_Sky_Intensity_CIE(Sun_azimuth_rad = None,Sun_elevation_rad = None,Sky_Particles_azimuth_rad = None,Sky_Particles_elevation_rad = None,CIE_Sky_number = None): 
    # INPUTS :
#Sun_Elevation, Sun_Azimuth, Sky_Particule_Elevation_Matrix, and
#Sky_Particule_Azimuth_Matrix are in radians.
# CIE_Sky_number takes integer value between 1 and 15.
    
    #Be carefull, CIE model is not effective for negative elevation.
    
    #  OUTPUTS :
# Skylight_Relative_Intensity is the matrix of normalized radiance of each
# direction in sky of azimuth and elevation given by
#Sky_Particule_Elevation_Matrix and Sky_Particule_Azimuth_Matrix.
# Always egal to 1 for elevation= pi/2. No definited maximum.
    
    #MEANING :
#This function returns, for given sun position and field observed, the
#relative sky radiance (visual value) accroding to CIE model.
    
    # CIE_coef Matrix : columns are for A B C D E coefficient and
# rows for 1 to 15 sky type :
    
    # 1  : CIE standard overcast sky, steep luminance gradation towards
#       zenith azimuthal uniformity
# 2  : Overcast, with steep luminance gradation and slight brightening
#       towards the sun
# 3  : Overcast, moderately graded with azimuthal uniformity
# 4  : Overcast, moderately graded and slight brightening towards the sun
# 5  : Sky of uniform luminance
# 6  : Partly cloudy sky, no gradation towards zenith, slight
#       brightening towards the sun
# 7  : Partly cloudy sky, no gradation towards zenith, brighter circumsolar
#       region
# 8  : Partly cloudy sky, no gradation towards zenith, distinct solar
#       corona
# 9  : Partly cloudy, with the obscured sun
# 10 : Partly cloudy, with brighter circumsolar region
# 11 : White-blue sky with distinct solar corona
# 12 : CIE standard clear sky, low luminance turbidity
# 13 : CIE standard clear sky, polluted atmosphere
# 14 : Cloudless turbid sky with broad solar corona
# 15 : White blue turbid sky with broad solar corona
    
    # REMINDER of CIE coeficients meaning:
    
    #A : horizon-zenith gradient, from -5 to 5
#B : gradient intensity, from -10 to 0
#C : circumsolar intensity, from 0 to 25
#D : circumsolar radius, from -10 to 0
#E : backscattering effect, from -1 to 5
    
    CIE_coef = np.array([[4.0,- 0.7,0,- 1,0],[4.0,- 0.7,2,- 1.5,0.15],[1.1,- 0.8,0,- 1,0],[1.1,- 0.8,2,- 1.5,0.15],[0,- 1,0,- 1,0],[0,- 1,2,- 1.5,0.15],[0,- 1,5,- 2.5,0.3],[0,- 1,10,- 3,0.45],[- 1,- 0.55,2,- 1.5,0.15],[- 1,- 0.55,5,- 2.5,0.3],[- 1,- 0.55,10,- 3,0.45],[- 1,- 0.32,10,- 3,0.45],[- 1,- 0.32,16,- 3,0.3],[- 1,- 0.15,16,- 3,0.3],[- 1,- 0.15,24,- 2.8,0.15]])
    #here some intermediate outcome
    x_sun = np.cos(Sun_elevation_rad) * np.cos(Sun_azimuth_rad)
    y_sun = np.cos(Sun_elevation_rad) * np.sin(Sun_azimuth_rad)
    z_sun = np.sin(Sun_elevation_rad)
    sun_zenith_angle_rad = np.pi / 2 - Sun_elevation_rad
    X_sky_particles = np.multiply(np.cos(Sky_Particles_elevation_rad),np.cos(Sky_Particles_azimuth_rad))
    Y_sky_particles = np.multiply(np.cos(Sky_Particles_elevation_rad),np.sin(Sky_Particles_azimuth_rad))
    Z_sky_particles = np.sin(Sky_Particles_elevation_rad)
    Sky_particles_zenith_angle_rad = np.pi / 2 - Sky_Particles_elevation_rad
    a_coef = CIE_coef[CIE_Sky_number-1,0]
    b_coef = CIE_coef[CIE_Sky_number-1,1]
    c_coef = CIE_coef[CIE_Sky_number-1,2]
    d_coef = CIE_coef[CIE_Sky_number-1,3]
    e_coef = CIE_coef[CIE_Sky_number-1,4]
    cos_scatt_angle = (x_sun * X_sky_particles + y_sun * Y_sky_particles + z_sun * Z_sky_particles)
    cos_square_scatt_angle = cos_scatt_angle ** 2
    scatt_angle_rad = np.arccos(cos_scatt_angle)
    #here phy ratio and f ratio in CIE model (see "Analysis of vertical sky
# components under various CIE standard general skies" by D.H.W. Li1,
# C. Li1, S.W. Lou1, E.K.W. Tsang2 and J.C. Lam, in 2015 ):
    Phy_CIE_ratio = (1 + a_coef * np.exp(b_coef / np.cos(Sky_particles_zenith_angle_rad))) / (1 + a_coef * np.exp(b_coef))
    f_CIE_ratio = (1 + c_coef * (np.exp(d_coef * scatt_angle_rad) - np.exp(d_coef * np.pi / 2)) + e_coef * cos_square_scatt_angle) / (1 + c_coef * (np.exp(d_coef * sun_zenith_angle_rad) - np.exp(d_coef * np.pi / 2)) + e_coef * (np.cos(sun_zenith_angle_rad) ** 2))
    #end of calculation
    Skylight_Relative_Intensity = np.multiply(Phy_CIE_ratio,f_CIE_ratio)
    return Skylight_Relative_Intensity
