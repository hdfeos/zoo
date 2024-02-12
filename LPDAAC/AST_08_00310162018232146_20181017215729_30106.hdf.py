"""

This example code illustrates how to access and visualize an LP DAAC AST_08 
swath file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python AST_08_00310162018232146_20181017215729_30106.hdf.py

The HDF-EOS2 file must be in your current working directory.

Tested under: Python 2.7.15 :: Anaconda custom (64-bit)
Last updated: 2018-11-05
"""

import os
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import pyproj
import numpy as np

# For GDAL based solution, please refer to [1].
# We will use pyhdf and HDF-EOS2 dumper tool [2]. 
from pyhdf.SD import SD, SDC

FILE_NAME = 'AST_08_00310162018232146_20181017215729_30106.hdf'
DATAFIELD_NAME = 'KineticTemperature'

hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data2D = hdf.select(DATAFIELD_NAME)
data = data2D[:,:].astype(np.double)


# Create geolocation dataset from HDF-EOS2 dumper v1.4.0 output.
# 
# Use the following command:
#
# $eos2dump -a1 AST_08_00310162018232146_20181017215729_30106.hdf SurfaceKineticTemperature > lat_AST_08_00310162018232146_20181017215729_30106.output
LAT_GEO_FILE_NAME = 'lat_AST_08_00310162018232146_20181017215729_30106.output'
lat = np.genfromtxt(LAT_GEO_FILE_NAME, delimiter=',', usecols=[0])
lat = lat.reshape(data.shape)

# Use the following command:
#
# $eos2dump -a2 AST_08_00310162018232146_20181017215729_30106.hdf SurfaceKineticTemperature > lon_AST_08_00310162018232146_20181017215729_30106.output
LON_GEO_FILE_NAME = 'lon_AST_08_00310162018232146_20181017215729_30106.output'
lon = np.genfromtxt(LON_GEO_FILE_NAME, delimiter=',', usecols=[0])
lon = lon.reshape(data.shape)

# Limit map based on min/max lat/lon values because the file covers a small region.
m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=np.min(lat), urcrnrlat=np.max(lat),
            llcrnrlon=np.min(lon), urcrnrlon=np.max(lon))            
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(np.floor(np.min(lat)), np.ceil(np.max(lat)), 0.1),
                labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(np.floor(np.min(lon)), np.ceil(np.max(lon)), 0.1),
                labels=[0, 0, 0, 1])
# See [3].
scale = 0.1
units = 'K'
data = scale * data
m.pcolormesh(lon, lat, data)
cb = m.colorbar()
cb.set_label(units)
    
basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}\n'.format(basename, DATAFIELD_NAME), fontsize=11)
    
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
    
# References
# [1] https://git.earthdata.nasa.gov/projects/LPDUR/repos/aster-l1t/browse
# [2] http://hdfeos.org/software/eosdump.php
# [3] https://asterweb.jpl.nasa.gov/content/03_data/01_Data_Products/release_surface_kinetic_temperatur.htm
