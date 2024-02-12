"""

This example code illustrates how to access and visualize an OBPG SNPP VIIRS
Swath netCDF-4 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python V2013335181200.L2_SNPP_OC.nc.py

Tested under: Python 3.7.3 :: Anaconda custom (x86_64)
Last Update: 2019-12-12
"""

import os
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from netCDF4 import Dataset
from mpl_toolkits.basemap import Basemap

# Open netCDF-4 file.
FILE_NAME = 'V2013335181200.L2_SNPP_OC.nc'
nc = Dataset(FILE_NAME)

# Read dataset.
DATAFIELD_NAME='chlor_a'
g = nc.groups['geophysical_data']
data = g.variables[DATAFIELD_NAME][:]
n = nc.groups['navigation_data']
latitude = n.variables['latitude'][:]
longitude = n.variables['longitude'][:]

# Set custom levels for plot.
levels = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 1.0, 2.0, 4.0, 8.0, 16.0, 32.0]
cmap = plt.get_cmap('jet')
norm = mpl.colors.BoundaryNorm(levels, cmap.N)

latmin = np.min(latitude)
latmax = np.max(latitude)
lonmin = np.min(longitude)
lonmax = np.max(longitude)

m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=latmin, urcrnrlat = latmax,
            llcrnrlon=lonmin, urcrnrlon = lonmax)

m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 45))
m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
m.pcolormesh(longitude, latitude, data, latlon=True, cmap=cmap, norm=norm)
cb = m.colorbar()
dset = g.variables[DATAFIELD_NAME]
units = dset.units
cb.set_label('Unit: '+units)
long_name = dset.long_name
plt.title('{0}\n {1}'.format(FILE_NAME, long_name))
fig = plt.gcf()

# Save plot.
pngfile = "{0}.py.png".format(FILE_NAME)
fig.savefig(pngfile)
