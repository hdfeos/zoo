"""
This example code illustrates how to access and visualize a LaRC CERES ES8
NOAA FM6 HDF-EOS2 Grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python CER_ES8_NOAA20-FM6_Edition1_101109.20220201.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2022-11-30
"""
import os

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from pyhdf.SD import SD, SDC
from mpl_toolkits.basemap import Basemap

# Open file.
FILE_NAME = 'CER_ES8_NOAA20-FM6_Edition1_101109.20220201.hdf'
hdf = SD(FILE_NAME, SDC.READ)
# print(hdf.datasets())

# Read dataset.
DATAFIELD_NAME = 'CERES LW flux at TOA'
data2D = hdf.select(DATAFIELD_NAME)
data = data2D[:,:]
        
# Read geolocation datasets.
lat = hdf.select('Colatitude of CERES FOV at TOA')
latitude = lat[:]
lon = hdf.select('Longitude of CERES FOV at TOA')
longitude = lon[:]

# Read attributes.
attrs = data2D.attributes(full=1)
la=attrs["long_name"]
long_name = la[0]
ua=attrs["units"]
units = ua[0]
fva=attrs["_FillValue"]
fillvalue = fva[0]

# Set fillvalue and units.
data[data == fillvalue] = np.nan
datam = np.ma.masked_array(data, mask=np.isnan(data))
    
# Adjust lat/lon values.
latitude = 90 - latitude
longitude[longitude>180]=longitude[longitude>180]-360;
    
# The data is global, so render in a global projection.
m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=-90, urcrnrlat=90,
            llcrnrlon=-180, urcrnrlon=180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90.,90,45))
m.drawmeridians(np.arange(-180.,180,45), labels=[True,False,False,True])
m.scatter(longitude, latitude, c=datam, s=1,
          cmap=plt.cm.jet, edgecolors=None, linewidth=0)

cb = m.colorbar()
cb.set_label(units)

basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, long_name))
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
