#
#   This example code illustrates how to access and visualize MASTER L1B
#  HDF4 file in Python. 
#
#   If you have any questions, suggestions, comments on this example, 
# please use the HDF-EOS Forum (http://hdfeos.org/forums).
#
#   If you would like to see an  example of any other NASA HDF/HDF-EOS data
# product that is not listed in the HDF-EOS Comprehensive Examples page 
# (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
# or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
#
# Usage: save this script and run 
#
# $python MASTERL1B_1300406_01_20130619_2135_2138_V01.hdf.py
#
# Tested under: Python 2.7.9
# Last updated: 2015-09-28


import os

import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

from pyhdf import HDF, SD, VS, V

# Open the HDF4 file.
FILE_NAME='MASTERL1B_1300406_01_20130619_2135_2138_V01.hdf'
sd = SD.SD(FILE_NAME)

# Read latitude.
DATAFIELD_NAME='AircraftLatitude'
sds = sd.select(DATAFIELD_NAME)
lat = sds[:].astype(np.float)
sds.endaccess()


# Read longitude.
DATAFIELD_NAME='AircraftLongitude';
sds = sd.select(DATAFIELD_NAME)
lon = sds[:].astype(np.float64)
sds.endaccess()

# Read data from a data field.
DATAFIELD_NAME='BlackBody1Temperature';
sds = sd.select(DATAFIELD_NAME)
data = sds[:].astype(np.float64)

# Read units attribute.
attrs = sds.attributes(full=1)
ua=attrs["units"]
units = ua[0]

sfa=attrs["scale_factor"]
scale_factor = sfa[0]        

fva=attrs["_FillValue"]
_FillValue = fva[0]

sds.endaccess()
sd.end()




# Replace the fill value with NaN
invalid = data == _FillValue
data[invalid] = np.nan


# Apply scale.
data = scale_factor*data;


m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=np.min(lat), urcrnrlat = np.max(lat),
            llcrnrlon=np.min(lon), urcrnrlon = np.max(lon))
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(np.floor(np.min(lat)), np.ceil(np.max(lat)), 1), labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(np.floor(np.min(lon)), np.ceil(np.max(lon)), 1), labels=[0, 0, 0, 1])
m.scatter(lon, lat, c=data, s=1, cmap=plt.cm.jet,
          edgecolors=None, linewidth=0)

cb = m.colorbar(location='bottom')
cb.set_label(units)

basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename,  DATAFIELD_NAME))
fig = plt.gcf()
# plt.show()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
