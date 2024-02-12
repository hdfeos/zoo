"""

This example code illustrates how to access and visualize a GESDISC TRMM 2B31
version 7 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python 2B31.20140108.91989.7.HDF.py

The HDF file must be in your current working directory.

Tested under: Python 2.7.13 :: Anaconda 4.3.22 
Last updated: 2017-12-07
"""
import os
import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.basemap import Basemap
from pyhdf.SD import SD, SDC

FILE_NAME = '2B31.20140108.91989.7.HDF'
hdf = SD(FILE_NAME, SDC.READ)
DATAFIELD_NAME = 'rrSurf'
ds = hdf.select(DATAFIELD_NAME)
data = ds[:,:].astype(np.double)

# No _FillValue attribute is defined.
# The value is -9999.9.
_FillValue = np.min(data)
data[data == _FillValue] = np.nan

# Handle attributes.
attrs = ds.attributes(full=1)
ua=attrs["units"]
units = ua[0]

# Retrieve the geolocation data.        
lat = hdf.select('Latitude')
latitude = lat[:,:]
lon = hdf.select('Longitude')
longitude = lon[:,:]

# Draw an equidistant cylindrical projection using the high resolution
# coastline database.
m = Basemap(projection='cyl', resolution='h')
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 45))
m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
m.scatter(longitude, latitude, c=data, s=0.1, cmap=plt.cm.jet,
          edgecolors=None, linewidth=0)
cb = m.colorbar()
cb.set_label(units)

basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, DATAFIELD_NAME))
fig = plt.gcf()
# plt.show()
    
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
