"""
This example code illustrates how to access and visualize a LaRC 
CERES ES8 J01 FM6 Edition1 file in in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python CER_ES8_J01-FM6_Edition1-CV_301310.20180730.hdf.py

The HDF4 file must be in your current working directory.

Tested under: Python 2.7.15 :: Anaconda custom (64-bit)
Last updated: 2018-08-10
"""
import os

import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np
from pyhdf.SD import SD, SDC

FILE_NAME = 'CER_ES8_J01-FM6_Edition1-CV_301310.20180730.hdf'
hdf = SD(FILE_NAME, SDC.READ)
# print(hdf.datasets())
DATAFIELD_NAME = 'CERES LW flux at TOA'

# Read dataset.
data2D = hdf.select(DATAFIELD_NAME)
data = data2D[:,:].astype(np.float64)

# Read attributes.
attrs = data2D.attributes(full=1)
fva = attrs["_FillValue"]
fillvalue = fva[0]
ua = attrs["units"]
units = ua[0]
ln = attrs["long_name"]
long_name = ln[0]        

# Handle fill value.
data[data == fillvalue] = np.nan
datam = np.ma.masked_array(data, mask=np.isnan(data))

# Read geolocation datasets.
lat = hdf.select('Colatitude of CERES FOV at TOA')
attrs = lat.attributes(full=1)
fva = attrs["_FillValue"]
fillvalue = fva[0]
colat= lat[:,:]
colat[colat == fillvalue] = np.nan
colatitude= np.ma.masked_array(colat, mask=np.isnan(colat))

lon = hdf.select('Longitude of CERES FOV at TOA')
attrs = lon.attributes(full=1)
fva = attrs["_FillValue"]
fillvalue = fva[0]
longf = lon[:,:]
longf[longf == fillvalue] = np.nan
longitude = np.ma.masked_array(longf, mask=np.isnan(longf))

# Adjust lat/lon.
longitude[longitude>180]=longitude[longitude>180]-360;
latitude = 90 - colatitude

# The data is global, so render in a global projection.
m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=-90, urcrnrlat=90,
            llcrnrlon=-180, urcrnrlon=180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90.,90,45))
m.drawmeridians(np.arange(-180.,180,45), labels=[True,False,False,True])
m.scatter(longitude, latitude, c=data, s=1, cmap=plt.cm.jet,
            edgecolors=None, linewidth=0)
cb = m.colorbar(location="bottom", pad='10%')    
cb.set_label(units)

basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, long_name))
fig = plt.gcf()
# plt.show()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)


