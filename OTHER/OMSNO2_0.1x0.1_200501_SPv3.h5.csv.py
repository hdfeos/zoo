"""
This example code illustrates how to access an GSFC Aura Data Validation Center
OMSNO2 HDF5 Grid file and save data in CSV using Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage: save this script and run

    $python OMSNO2_0.1x0.1_200501_SPv3.h5.csv.py


Tested under: Python 3.9.1 :: Miniconda
Last updated: 2021-06-07
"""
import os
import re
import h5py
import numpy as np

FILE_NAME = 'OMSNO2_0.1x0.1_200501_SPv3.h5'    
DATAFIELD_NAME = '/OMI_SurfNO2'
with h5py.File(FILE_NAME, mode='r') as f:
    
    # Read data.    
    dset = f[DATAFIELD_NAME]
    data = dset[:]

    # Read longitude.
    x = f['/Longitude'][:]
    # Read latitude.
    y = f['/Latitude'][:]

    nx, ny = data.shape
    lon, lat = np.meshgrid(x, y)
    a = np.array([lon.flatten(), lat.flatten(), data.flatten()])
    basename = os.path.basename(FILE_NAME)
    np.savetxt('{0}.csv.py.csv'.format(basename), a.T, delimiter=',', 
               header='lon,lat,omi_no2')

