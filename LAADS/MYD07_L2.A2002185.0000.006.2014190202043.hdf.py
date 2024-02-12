"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize a LAADS MYD07 v6
HDF-EOS2 Swath file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python MYD07_L2.A2002185.0000.006.2014190202043.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 2.7.14 :: Anaconda custom (64-bit)
Last updated: 2018-02-19
"""
import os
import matplotlib as mpl
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
import numpy as np

FILE_NAME = 'MYD07_L2.A2002185.0000.006.2014190202043.hdf'
DATAFIELD_NAME = 'Water_Vapor'

from pyhdf.SD import SD, SDC
hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data2D = hdf.select(DATAFIELD_NAME)
data = data2D[:,:].astype(np.double)

# Read geolocation dataset.
lat = hdf.select('Latitude')
latitude = lat[:,:]
lon = hdf.select('Longitude')
longitude = lon[:,:]

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
ua=attrs["units"]
units = ua[0]

data[data == _FillValue] = np.nan
data = (data - add_offset) * scale_factor 
datam = np.ma.masked_array(data, np.isnan(data))

# Find middle location.
lat_m = latitude[latitude.shape[0]/2,latitude.shape[1]/2]
lon_m = longitude[longitude.shape[0]/2,longitude.shape[1]/2]

# Use the following for Geographic projection.
# ax = plt.axes(projection=ccrs.PlateCarree())

# Let's use ortho projection.
orth = ccrs.Orthographic(central_longitude=lon_m,
                         central_latitude=lat_m,
                        globe=None)
ax = plt.axes(projection=orth)

# Remove the following to see zoom-in view.
ax.set_global()
p = plt.pcolormesh(longitude, latitude, datam, transform=ccrs.PlateCarree())

# Gridline with draw_labels=True doesn't work on ortho.
# ax.gridlines(draw_labels=True)
ax.gridlines()
ax.coastlines()
cb = plt.colorbar(p)
cb.set_label(units, fontsize=8)

# Put title.
basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, long_name))
fig = plt.gcf()

# Save image.
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
    
