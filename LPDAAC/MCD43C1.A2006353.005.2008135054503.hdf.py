"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize an LP DAAC MCD43C1
v5 HDF-EOS2 Grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MCD43C1.A2006353.005.2008135054503.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 2.7.14 :: Anaconda custom (64-bit)
Last updated: 2018-03-26
"""

import os
import re

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
from pyhdf.SD import SD, SDC
from mpl_toolkits.basemap import Basemap

FILE_NAME = 'MCD43C1.A2006353.005.2008135054503.hdf'
# Identify the data field.
DATAFIELD_NAME = 'BRDF_Albedo_Parameter1_Band2'

hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data2D = hdf.select(DATAFIELD_NAME)
data = data2D[:,:].astype(np.double)

# Read attributes.
attrs = data2D.attributes(full=1)
lna=attrs["long_name"]
long_name = lna[0]
vra=attrs["valid_range"]
valid_range = vra[0]
aoa=attrs["add_offset"]
add_offset = aoa[0]
fva=attrs["_FillValue"]
_FillValue = fva[0]
sfa=attrs["scale_factor"]
scale_factor = sfa[0]        
ua=attrs["units"]
units = ua[0]

# Handle fill value.
invalid = data == _FillValue
invalid = np.logical_or(invalid, data < valid_range[0])
invalid = np.logical_or(invalid, data > valid_range[1])
data[invalid] = np.nan

# Apply scale factor and offset.
data = scale_factor * (data - add_offset)
data = np.ma.masked_array(data, np.isnan(data))
        
# Normally we would use the grid metadata to reconstruct the grid, but
# the grid metadata is incorrect in this case, specifically the upper left
# and lower right coordinates of the grid.  We'll construct the grid
# manually, taking into account the fact that we're going to subset the
# data by a factor of 10 (the grid size is 3600 x 7200).
x = np.linspace(-180, 180, 720)
y = np.linspace(90, -90, 360)
lon, lat = np.meshgrid(x, y)

m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=-90, urcrnrlat=90,
            llcrnrlon=-180, urcrnrlon=180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 90, 45), labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(-180, 181, 45), labels=[0, 0, 0, 1])
m.pcolormesh(lon, lat, data[::10,::10])
cb = m.colorbar()
cb.set_label(units)

basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, long_name))
    
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
