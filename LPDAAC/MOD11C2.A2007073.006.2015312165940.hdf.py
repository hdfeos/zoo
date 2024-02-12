"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize an LP DAAC MOD11C2
v6 HDF-EOS2 Grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MOD11C2.A2007073.006.2015312165940.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 2.7.14 :: Anaconda custom (64-bit)
Last updated: 2018-04-16
"""

import os
import re

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
from pyhdf.SD import SD, SDC
from mpl_toolkits.basemap import Basemap

FILE_NAME = 'MOD11C2.A2007073.006.2015312165940.hdf'

# Identify the data field.
DATAFIELD_NAME = 'LST_Night_CMG'

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
data = (data - add_offset) * scale_factor 
data = np.ma.masked_array(data, np.isnan(data))
        
# We'll construct the grid manually.
x = np.linspace(-180, 180, data.shape[1])
y = np.linspace(90, -90, data.shape[0])
lon, lat = np.meshgrid(x, y)

m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=-90, urcrnrlat=90,
            llcrnrlon=-180, urcrnrlon=180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 90, 45), labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(-180, 181, 45), labels=[0, 0, 0, 1])
m.pcolormesh(lon, lat, data)
cb = m.colorbar()
cb.set_label(units)

basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, long_name))
    
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
