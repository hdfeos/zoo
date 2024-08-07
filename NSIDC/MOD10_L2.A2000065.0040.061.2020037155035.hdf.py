"""

This example code illustrates how to access and visualize a NSIDC Level-2
MODIS HDF-EOS2 Swath data file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MOD10_L2.A2000065.0040.061.2020037155035.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2024-08-06
"""

import os

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import colors
from mpl_toolkits.basemap import Basemap
from pyhdf.SD import SD, SDC

FILE_NAME = "MOD10_L2.A2000065.0040.061.2020037155035.hdf"
DATAFIELD_NAME = "NDSI_Snow_Cover"

hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data2D = hdf.select(DATAFIELD_NAME)

# Use the following for low resolution.
# This is good for low memory machine.
rows = slice(5, 4060, 10)
cols = slice(5, 2708, 10)
data = data2D[rows, cols]
latitude = hdf.select("Latitude")[:]
longitude = hdf.select("Longitude")[:]

# Read dataset attribute.
attrs = data2D.attributes(full=1)
lna = attrs["long_name"]
long_name = lna[0]

# Use the following for high resolution.
# This may not work for low memory machine.

# data = data2D[:,:]
# Read geolocation dataset from HDF-EOS2 dumper output.
# GEO_FILE_NAME = 'lat_MOD10_L2.A2000065.0040.005.2008235221207.output'
# lat = np.genfromtxt(GEO_FILE_NAME, delimiter=',', usecols=[0])
# latitude = lat.reshape(data.shape)
# GEO_FILE_NAME = 'lon_MOD10_L2.A2000065.0040.005.2008235221207.output'
# lon = np.genfromtxt(GEO_FILE_NAME, delimiter=',', usecols=[0])
# longitude = lon.reshape(data.shape)

# Draw a polar stereographic projection using the low resolution coastline
# database.
m = Basemap(projection="npstere", resolution="l", boundinglat=64, lon_0=0)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(60.0, 81, 10.0))
m.drawmeridians(
    np.arange(-180.0, 181.0, 30.0), labels=[True, False, False, True]
)

#  Key: = 0-100=ndsi snow, 200=missing data,
# 201=no decision, 211=night, 237=inland water, 239=ocean,
# 250=cloud, 254=detector saturated, 255=fill
# Use a discretized colormap since we have only two levels.
cmap = colors.ListedColormap(["purple", "blue"])

# Define the bins and normalize for discrete colorbar.
bounds = np.array([211.0, 237.0, 239.0])
norm = mpl.colors.BoundaryNorm(bounds, cmap.N)
m.pcolormesh(longitude, latitude, data, latlon=True, cmap=cmap, norm=norm)
cb = plt.colorbar()

# Put label in the middle.
cb.set_ticks([224.0, 238.0])
cb.set_ticklabels(["night", "inland water"])

basename = os.path.basename(FILE_NAME)
plt.title("{0}\n{1}".format(basename, long_name))
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
