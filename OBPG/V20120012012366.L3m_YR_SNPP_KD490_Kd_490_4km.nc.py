"""

This example code illustrates how to access and visualize a OBPG S-NPP VIIRS
Grid netCDF-4 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage: save this script and run

    $python V20120012012366.L3m_YR_SNPP_KD490_Kd_490_4km.nc.py

Tested under: Python 3.7.3 :: Anaconda custom (x86_64)
Last Update: 2020-01-03
"""

import os
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from netCDF4 import Dataset
from mpl_toolkits.basemap import Basemap

# Open netCDF-4 file.
FILE_NAME = 'V20120012012366.L3m_YR_SNPP_KD490_Kd_490_4km.nc'
nc = Dataset(FILE_NAME)

# Read dataset.
DATAFIELD_NAME='Kd_490'
dset = nc.variables[DATAFIELD_NAME]
data = dset[:]
latitude = nc.variables['lat'][:]
longitude = nc.variables['lon'][:]

# Dataset is too big for plotting.
# Subset every n-th point to visualize data.
n = 2
data = data[::n, ::n]
latitude = latitude[::n]
longitude = longitude[::n]

# Set custom levels for plot.
levels = [0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 7]
cmap = plt.get_cmap('jet')
norm = mpl.colors.BoundaryNorm(levels, cmap.N)

m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=-90, urcrnrlat = 90,
            llcrnrlon=-180, urcrnrlon = 180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 45))
m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
m.pcolormesh(longitude, latitude, data, latlon=True, cmap=cmap, norm=norm)
cb = m.colorbar()
dset = nc.variables[DATAFIELD_NAME]
units = dset.units
cb.set_label('Unit: '+units)
long_name = dset.long_name
plt.title('{0}\n {1}'.format(FILE_NAME, long_name))
fig = plt.gcf()

# Save plot.
pngfile = "{0}.py.png".format(FILE_NAME)
fig.savefig(pngfile)

