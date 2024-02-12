"""

This example code illustrates how to access and visualize an LP DAAC AST L1T
swath file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python AST_L1T_00307032007164549_20150520034236_114188.hdf.py

The HDF file must be in your current working directory.
"""

import os
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import mpl_toolkits.basemap.pyproj as pyproj
import numpy as np

# For GDAL based solution, please refer to [1].
# We will use pyhdf and HDF-EOS2 dumper tool [2]. 
from pyhdf.SD import SD, SDC

FILE_NAME = 'AST_L1T_00307032007164549_20150520034236_114188.hdf'
DATAFIELD_NAME = 'ImageData4'

hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data2D = hdf.select(DATAFIELD_NAME)
data = data2D[:,:].astype(np.double)


# Create geolocation dataset from HDF-EOS2 dumper output.
# 
# Use the following command:
#
# $eos2dump -a1 AST_L1T_00307032007164549_20150520034236_114188.hdf SWIR_Swath > lat_AST_L1T_00307032007164549_20150520034236_114188.output
LAT_GEO_FILE_NAME = 'lat_AST_L1T_00307032007164549_20150520034236_114188.output'
lat = np.genfromtxt(LAT_GEO_FILE_NAME, delimiter=',', usecols=[0])
lat = lat.reshape(data.shape)

# Use the following command:
#
# $eos2dump -a2 AST_L1T_00307032007164549_20150520034236_114188.hdf SWIR_Swath > lon_AST_L1T_00307032007164549_20150520034236_114188.output
LON_GEO_FILE_NAME = 'lon_AST_L1T_00307032007164549_20150520034236_114188.output'
lon = np.genfromtxt(LON_GEO_FILE_NAME, delimiter=',', usecols=[0])
lon = lon.reshape(data.shape)

# Limit map based on min/max lat/lon values because the file covers a small region.
m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=np.min(lat), urcrnrlat=np.max(lat),
            llcrnrlon=np.min(lon), urcrnrlon=np.max(lon))            
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(np.floor(np.min(lat)), np.ceil(np.max(lat)), 1), labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(np.floor(np.min(lon)), np.ceil(np.max(lon)), 1), labels=[0, 0, 0, 1])

m.pcolormesh(lon, lat, data)
cb = m.colorbar()

basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}\n'.format(basename, DATAFIELD_NAME), fontsize=11)
    
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
    
# References
# [1] https://git.earthdata.nasa.gov/projects/LPDUR/repos/aster-l1t/browse
# [2] http://hdfeos.org/software/eosdump.php
