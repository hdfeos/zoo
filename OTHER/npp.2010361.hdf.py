#  This example code illustrates how to access and visualize Ocean Productivity
#  net primary production (npp) HDF4 file in Python.
#
#  If you have any questions, suggestions, comments  on this example, 
# pleaseuse the HDF-EOS Forum (http://hdfeos.org/forums). 
#
#  If you would like to see an  example of any other NASA
# HDF/HDF-EOS data product that is not listed in the
# HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
# feel free to contact us at eoshelp@hdfgroup.org or post it at the
# HDF-EOS Forum (http://hdfeos.org/forums).
#
# Usage: save this script and run 
#
# $python npp.2010361.hdf.py
#
# Tested under: Python 2.7.9
# Last updated: 2015-09-29

import os

import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np
from pyhdf import SD



# Open the HDF4 file.
FILE_NAME='npp.2010361.hdf';
sd = SD.SD(FILE_NAME)

# Read data from a data field.
DATAFIELD_NAME='npp';
sds = sd.select(DATAFIELD_NAME)
data = sds[:,:].astype(np.float32)

# Read attributes.
attrs = sds.attributes(full=1)
ua=attrs["Units"]
units = ua[0]

fva=attrs["Hole Value"]
_FillValue = fva[0]
sds.endaccess()
sd.end()

# Set lat / lon variable based on FAQ [2].
x = np.linspace(-179.5, 179.5, 4320)
y = np.linspace(-89.5, 89.5, 2160)[::-1]
longitude, latitude = np.meshgrid(x, y)

# The max value goes up to 13K. Limit the value to get a good plot ...
#  like [2].
data[(data > 1000.0)] = 1000.0

# Replace the fill value with NaN
invalid = data == _FillValue
data[invalid] = np.nan
data = np.ma.array(data, mask=np.isnan(data))

# Draw a map using the low resolution coastline database.
m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=-90, urcrnrlat=90,
            llcrnrlon=-180, urcrnrlon=180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 45))
m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
mesh = m.pcolormesh(longitude, latitude, data, latlon=True)
cb = m.colorbar()
cb.set_label(units)    

basename = os.path.basename(FILE_NAME)
fig = plt.gcf()
fig.suptitle('{0}\n{1}'.format(basename, DATAFIELD_NAME))
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)

# References
# [1] http://orca.science.oregonstate.edu/2160.by.4320.8day.hdf.vgpm.m.chl.m.sst4.php
# [2] http://orca.science.oregonstate.edu/faq01.php
# [3] http://www.science.oregonstate.edu/ocean.productivity/standard.product.php

