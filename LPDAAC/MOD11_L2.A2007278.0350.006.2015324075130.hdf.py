"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize an LP DAAC MOD11
v6 swath file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python MOD11_L2.A2007278.0350.006.2015324075130.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 2.7.14 :: Anaconda custom (64-bit)
Last updated: 2018-04-13
"""
import os
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from pyhdf.SD import SD, SDC
from mpl_toolkits.basemap import Basemap

FILE_NAME = 'MOD11_L2.A2007278.0350.006.2015324075130.hdf'
GEO_FILE_NAME = 'MOD03.A2007278.0350.006.2012240120846.hdf'
DATAFIELD_NAME = 'LST'

hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data2D = hdf.select(DATAFIELD_NAME)
data = data2D[:,:].astype(np.double)

hdf_geo = SD(GEO_FILE_NAME, SDC.READ)

# Read geolocation dataset from MOD03 product.
latitude = hdf_geo.select('Latitude')
lat = latitude[:,:]
longitude = hdf_geo.select('Longitude')
lon = longitude[:,:]
        
# Retrieve attributes.
attrs = data2D.attributes(full=1)
lna=attrs["long_name"]
long_name = lna[0]
aoa=attrs["add_offset"]
add_offset = aoa[0]
fva=attrs["_FillValue"]
_FillValue = fva[0]
sfa=attrs["scale_factor"]
scale_factor = sfa[0]        
vra=attrs["valid_range"]
valid_min = vra[0][0]        
valid_max = vra[0][1]        
ua=attrs["units"]
units = ua[0]
        
invalid = np.logical_or(data > valid_max,
                        data < valid_min)
invalid = np.logical_or(invalid, data == _FillValue)
data[invalid] = np.nan
data = (data - add_offset) * scale_factor 
data = np.ma.masked_array(data, np.isnan(data))

# Draw an equidistant cylindrical projection using the low resolution
# coastline database.
m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=np.min(lat), urcrnrlat=np.max(lat),
            llcrnrlon=np.min(lon), urcrnrlon=np.max(lon))
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(10, 40, 5), labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(90, 130, 10), labels=[0, 0, 0, 1])
m.pcolormesh(lon, lat, data, latlon=True)
cb = m.colorbar()
cb.set_label(units)

basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, long_name))
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)


    