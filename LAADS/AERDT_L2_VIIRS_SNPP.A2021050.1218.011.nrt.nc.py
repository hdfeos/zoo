"""

This example code illustrates how to access and visualize a LAADS 
AERDT_L2_VIIRS_SNPP_NRT netCDF-4/HDF5 Swath file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage: save this script and run

    $python AERDT_L2_VIIRS_SNPP.A2021050.1218.011.nrt.nc.py

The HDF-EOS file must be in your current working directory.

Tested under: Python 3.7.3 :: Anaconda custom (64-bit)
Last updated: 2021-02-19
"""
import os
import h5py
import matplotlib as mpl
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
import numpy as np
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER

# Open file.
FILE_NAME = 'AERDT_L2_VIIRS_SNPP.A2021050.1218.011.nrt.nc'
with h5py.File(FILE_NAME, mode='r') as f:
    # Read data.
    name = '/geophysical_data/Image_Optical_Depth_Land_And_Ocean'
    data = f[name][:].astype(np.float64)

    # Read attributes.
    scale = f[name].attrs['scale_factor']
    offset = f[name].attrs['add_offset']
    units = f[name].attrs['units'].decode()
    long_name = f[name].attrs['long_name'].decode()
    _FillValue = f[name].attrs['_FillValue']
    
    # Get the geolocation data
    lat = f['/geolocation_data/latitude'][:]
    lon = f['/geolocation_data/longitude'][:]
    
# Handle FillValue
data[data == _FillValue] = np.nan
data = np.ma.masked_where(np.isnan(data), data)

# Apply scale and offset.
data = scale * data + offset
# Find middle location.
lat_m = lat[int(lat.shape[0]/2),int(lat.shape[1]/2)]
lon_m = lon[int(lon.shape[0]/2),int(lon.shape[1]/2)]

# Let's use ortho projection.
orth = ccrs.Orthographic(central_longitude=lon_m,
                         central_latitude=lat_m,
                         globe=None)
ax = plt.axes(projection=orth)

# Remove the following to see zoom-in view.
# ax.set_global()

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

# Long name is too long. Cut in the middle space.
index = long_name.find(" ", int(len(long_name)/2))
plt.title('{0}\n{1}\n{2}'.format(basename, long_name[:index], long_name[index:]),
          fontsize=8)
fig = plt.gcf()

# Save image.
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)

