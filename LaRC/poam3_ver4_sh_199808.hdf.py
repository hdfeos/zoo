"""
This example code illustrates how to access and visualize POAM3 in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python poam3_ver4_sh_199808.hdf.py

The HDF file must be in your current working directory.


Tested under: Python 3.9.1::Miniconda
Last updated: 2022-04-12
"""

import os

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from matplotlib import colors
from mpl_toolkits.basemap import Basemap
from pyhdf.SD import SD, SDC

FILE_NAME = 'poam3_ver4_sh_199808.hdf'
DATAFIELD_NAME = 'ozone'
hdf = SD(FILE_NAME, SDC.READ)
        
# Read dataset.
a = 55
data2D = hdf.select(DATAFIELD_NAME)
data = data2D[a,]
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

# Read geolocation datasets.
latitude = hdf.select('lat')
lat = latitude[:]
longitude = hdf.select('lon')
lon = longitude[:]
lon[lon>180]=lon[lon>180]-360
altitude = hdf.select('z_ozone')
alt = altitude[:]
attrs = altitude.attributes(full=1)
ua=attrs["units"]
aunits = ua[0]

# The data is global, so render in a global projection.
m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=-90, urcrnrlat=90,
            llcrnrlon=-180, urcrnrlon=180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90.,90,45))
m.drawmeridians(np.arange(-180.,180,45), labels=[True,False,False,True])
m.scatter(lon, lat, c=datam, s=0.5, cmap=plt.cm.jet, edgecolors=None,
          linewidth=0)
cb = m.colorbar()
cb.set_label(units)

basename = os.path.basename(FILE_NAME)
pngfile = "{0}.py.png".format(basename)
plt.title('{0}\n{1} at Altitude={2} ({3})'.format(basename, long_name,
                                                  str(alt[a]), aunits))
fig = plt.gcf()
fig.savefig(pngfile)
