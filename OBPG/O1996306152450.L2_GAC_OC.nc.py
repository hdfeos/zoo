"""

This example code illustrates how to access and visualize a OBPG OCTS Swath 
netCDF-4 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python O1996306152450.L2_GAC_OC.nc.py

The OCTS file must be in your current working directory.

Tested under: Python 3.7.3 :: Anaconda custom (x86_64)
Last Update: 2019-11-13
"""

import os
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from netCDF4 import Dataset
from mpl_toolkits.basemap import Basemap

# Open netCDF-4 file.
FILE_NAME = 'O1996306152450.L2_GAC_OC.nc'
nc = Dataset(FILE_NAME)

# Read dataset.
DATAFIELD_NAME='Rrs_412'
g = nc.groups['geophysical_data']
data = g.variables[DATAFIELD_NAME][:]
n = nc.groups['navigation_data']
latitude = n.variables['latitude'][:]
longitude = n.variables['longitude'][:]

m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=-90, urcrnrlat = 90,
            llcrnrlon=-180, urcrnrlon = 180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 45))
m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
m.scatter(longitude, latitude, c=data, s=1, cmap=plt.cm.jet,
          edgecolors=None, linewidth=0)
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