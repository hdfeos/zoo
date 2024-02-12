"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize an LaRC MISR SOM
grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MISR_AM1_TC_ALBEDO_P223_O056884_F05_0011.hdf.py

The HDF file and HDF-EOS2 Dumper output lat/lon files must be in your current 
working directory.

o
Tested under: Python 2.7.15 :: Anaconda custom (64-bit)
Last updated: 2018-08-16
"""

import os
import re


import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np
from pyhdf.SD import SD, SDC

FILE_NAME = 'MISR_AM1_TC_ALBEDO_P223_O056884_F05_0011.hdf'
hdf = SD(FILE_NAME, SDC.READ)

# Identify the data field.
DATAFIELD_NAME = 'AlbedoLocal'

# Read dataset.
data4D = hdf.select(DATAFIELD_NAME)

# Convert 4-D data to 2-D data by subsetting.
SOMBlockDim = 50;
NBandDim = 0;
data = data4D[SOMBlockDim,:,:,NBandDim].astype(np.double)
        
# Read attributes.
attrs = data4D.attributes(full=1)
fva=attrs["_FillValue"]
_FillValue = fva[0]

# Apply the fill value.
data[data == _FillValue] = np.nan
datam = np.ma.masked_array(data, mask=np.isnan(data))


# Read geolocation dataset from HDF-EOS2 dumper output.
GEO_FILE_NAME = 'lat_MISR_AM1_TC_ALBEDO_P223_O056884_F05_0011.output'
lat = np.genfromtxt(GEO_FILE_NAME, delimiter=',', usecols=[0])
lat = lat.reshape(data.shape)
    
GEO_FILE_NAME = 'lon_MISR_AM1_TC_ALBEDO_P223_O056884_F05_0011.output'
lon = np.genfromtxt(GEO_FILE_NAME, delimiter=',', usecols=[0])
lon = lon.reshape(data.shape)

# Set the limit for the plot.
m = Basemap(projection='cyl', resolution='h',
            llcrnrlat=np.min(lat), urcrnrlat = np.max(lat),
            llcrnrlon=np.min(lon), urcrnrlon = np.max(lon))
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(np.floor(np.min(lat)), np.ceil(np.max(lat)), 1), labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(np.floor(np.min(lon)), np.ceil(np.max(lon)), 1), labels=[0, 0, 0, 1])
m.pcolormesh(lon, lat, datam, latlon=True)
cb = m.colorbar()
cb.set_label('No Unit')

basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1} at SOMBlockDim=50 NBandDim=0'.format(basename, DATAFIELD_NAME))
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
