"""

This example code illustrates how to access and visualize a LaRC ASDC
DSCOVR_EPIC L2 HDF5 Swath file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage: save this script and run

    $python DSCOVR_EPIC_L2_TO3_03_20210301005516_03.h5.py


The HDF-EOS file must be in your current working directory.

Tested under: Python 3.7.7 :: Anaconda custom (64-bit)
Last updated: 2021-03-19
"""
import os
import h5py
import matplotlib as mpl
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
import numpy as np
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER

# Open file.
FILE_NAME = 'DSCOVR_EPIC_L2_TO3_03_20210301005516_03.h5'
with h5py.File(FILE_NAME, mode='r') as f:
    # Read data.
    name = '/Ozone'
    data = f[name][:].astype(np.float64)

    # Read attributes.
    units = 'DU'
    long_name = 'Ozone'
    
    # Get the geolocation data
    lat = f['/Latitude'][:]
    lon = f['/Longitude'][:]
    
# Handle FillValue
_FillValue = -999.0
data[data == _FillValue] = np.nan
data = np.ma.masked_where(np.isnan(data), data)

# Find middle location.
lat_m = lat[int(lat.shape[0]/2),int(lat.shape[1]/2)]
lon_m = lon[int(lon.shape[0]/2),int(lon.shape[1]/2)]

# Use ortho projection.
orth = ccrs.Orthographic(central_longitude=lon_m,
                         central_latitude=lat_m,
                         globe=None)
ax = plt.axes(projection=orth)

# Plot on map.
p = plt.scatter(lon, lat, c=data, s=1, cmap=plt.cm.jet,
                transform=ccrs.PlateCarree())
# Put grids.
gl = ax.gridlines()

# Put coast lines.
ax.coastlines()

# Put grid labels only at left and bottom.
gl.top_labels = False
gl.right_labels = False

# Put degree N/E label.
gl.xformatter = LONGITUDE_FORMATTER
gl.yformatter = LATITUDE_FORMATTER

# Adjust colorbar size and location using fraction and pad.
cb = plt.colorbar(p, fraction=0.022, pad=0.01)
cb.set_label(units, fontsize=8)

# Put title.
basename = os.path.basename(FILE_NAME)

plt.title('{0}\n{1}'.format(basename, long_name), fontsize=12)
fig = plt.gcf()

# Save image.
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)

