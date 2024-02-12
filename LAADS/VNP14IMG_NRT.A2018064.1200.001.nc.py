"""

This example code illustrates how to access and visualize a LAADS VNP14IMG_NRT
v1 netCDF-4/HDF5 Swath file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python VNP14IMG_NRT.A2018064.1200.001.nc.py

The HDF-EOS2 file must be in your current working directory.

Tested under: Python 2.7.14 :: Anaconda custom (64-bit)
Last updated: 2018-03-07
"""
import os
import h5py
import matplotlib as mpl
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
import numpy as np
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER

# Open file.
FILE_NAME = 'VNP14IMG_NRT.A2018064.1200.001.nc'
with h5py.File(FILE_NAME, mode='r') as f:
    # Read data.
    name = '/FP_T5'
    data = f[name][:]

    # Read attributes.
    units = f[name].attrs['units'][0] 
    long_name = f[name].attrs['long_name'][0]

    # Get the geolocation data
    lat = f['/FP_latitude'][:]
    lon = f['/FP_longitude'][:]
    
# Find middle location.
lat_m = lat[lat.shape[0]/2]
lon_m = lon[lon.shape[0]/2]

# Let's use ortho projection.
orth = ccrs.Orthographic(central_longitude=lon_m,
                         central_latitude=lat_m,
                         globe=None)
ax = plt.axes(projection=orth)

# Remove the following to see zoom-in view.
ax.set_global()

# Plot on map.
p = plt.scatter(lon, lat, c=data, s=1, cmap=plt.cm.jet,
                transform=ccrs.PlateCarree())
# Put grids.
gl = ax.gridlines()

# Put coast lines.
ax.coastlines()

# Put grid labels only at left and bottom.
gl.xlabels_top = False
gl.ylabels_right = False

# Put degree N/E label.
gl.xformatter = LONGITUDE_FORMATTER
gl.yformatter = LATITUDE_FORMATTER

# Adjust colorbar size and location using fraction and pad.
cb = plt.colorbar(p, fraction=0.022, pad=0.01)
cb.set_label(units, fontsize=8)

# Put title.
basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, long_name), fontsize=8)
fig = plt.gcf()

# Save image.
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)

