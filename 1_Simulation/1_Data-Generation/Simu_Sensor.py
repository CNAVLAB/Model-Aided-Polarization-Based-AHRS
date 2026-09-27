import numpy as np
    
def Simu_Sensor(Intensity_on_pixels = None,pixel_saturation_ratio = None,number_of_bits = None,SNR_gauss = None): 
    #  INPUTS :
#Intensity_on_pixels : no unit, postive value (matrix)
#pixel_saturation_ratio : no unit, positive value
#number_of_bits : positive integer
#SNR_gauss : no unit positive value
    
    #  OUTPUTS :
#Bits_Matrix : Grayscale
    
    #  MEANING :
#This function takes four inputs:
# - The relative energetic irradicane matrix (sensor-sized) describing light
# irrdiance on each pixel.
# - A saturation ration which is the ratio between irradiance saturation
# value and maximum relative irradiance comming on sensor's pixels.
# - The number of bits the sensor return the information in
# - The Signal Noise Ratio for gaussian noise en sensor.
# This function returns the camera output bits matrix (grayscale image).
    
    with_noise_matrix = np.multiply((1 / SNR_gauss) * Intensity_on_pixels,np.random.randn(Intensity_on_pixels.shape[0],Intensity_on_pixels.shape[1])) + Intensity_on_pixels
    max_pixel_value = (2 ** number_of_bits) - 1
    max_intensity_comming_on_pixels = np.amax(np.amax(Intensity_on_pixels))
    Bits_Matrix = np.minimum((np.floor((max_pixel_value / (max_intensity_comming_on_pixels * pixel_saturation_ratio)) * with_noise_matrix)).astype(int),max_pixel_value)
    return Bits_Matrix
