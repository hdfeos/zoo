"""

This example code illustrates how to access and visualize a OBPG MODIS Aqua
 Grid netCDF-4 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage: save this script and run

    $python A20021612002192.L3m_R32_SST_sst_4km.nc.py

Tested under: Python 3.7.3 :: Anaconda custom (x86_64)
Last Update: 2019-12-10
"""

import os
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from netCDF4 import Dataset
from mpl_toolkits.basemap import Basemap

# Open netCDF-4 file.
FILE_NAME = 'A20021612002192.L3m_R32_SST_sst_4km.nc'
nc = Dataset(FILE_NAME)

# Read dataset.
DATAFIELD_NAME='sst'
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

m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=-90, urcrnrlat = 90,
            llcrnrlon=-180, urcrnrlon = 180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 45))
m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
m.pcolormesh(longitude, latitude, data, latlon=True)
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

