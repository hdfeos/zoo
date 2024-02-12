"""

This example code illustrates how to access and visualize a LAADS VNP09_NRT v1
HDF-EOS2 Swath file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python VNP09_NRT.A2018064.0524.001.hdf.py

The HDF-EOS2 file file and netCDF-4/HDF5 geolocation file [1] must be in your 
current working directory.

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
FILE_NAME = 'VNP09_NRT.A2018064.0524.001.hdf'
GEO_FILE_NAME = 'VNP03IMG_NRT.A2018064.0524.001.nc'
DATAFIELD_NAME = '375m Surface Reflectance Band I1'

from pyhdf.SD import SD, SDC
hdf = SD(FILE_NAME, SDC.READ)
# print hdf.datasets()

# Read dataset.
data_raw = hdf.select(DATAFIELD_NAME)
data = data_raw[:,:].astype(np.double)

# Read lat/lon.
with h5py.File(GEO_FILE_NAME, mode='r') as f:
    # Get the geolocation data
    lat = f['/geolocation_data/latitude'][:]
    lon = f['/geolocation_data/longitude'][:]


# Retrieve attributes.
attrs = data_raw.attributes(full=1)
long_name = DATAFIELD_NAME
sfa=attrs["Scale"]
scale_factor = sfa[0]        
aoa=attrs["Offset"]
add_offset = aoa[0]
fva=attrs["FILL_VALUES"]
# There are several fill values.
# print(fva)
_FillValue = -28672
data[data == _FillValue] = np.nan
_FillValue = -994
data[data == _FillValue] = np.nan
_FillValue = -993
data[data == _FillValue] = np.nan
_FillValue = -992
data[data == _FillValue] = np.nan
_FillValue = -100
data[data == _FillValue] = np.nan
data =  scale_factor * (data - add_offset)

# Find middle location.
lat_m = lat[lat.shape[0]/2,lat.shape[1]/2]
lon_m = lon[lon.shape[0]/2,lon.shape[1]/2]

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

# See user guide [2].
units = 'Reflectance'
cb.set_label(units, fontsize=8)

# Put title.
basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, long_name), fontsize=8)
fig = plt.gcf()

# Save image.
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)

# References
# [1] ftp://nrt3.modaps.eosdis.nasa.gov/allData/5001/VNP03IMG_NRT/
# [2] https://viirsland.gsfc.nasa.gov/PDF/VIIRS_Surf_Refl_UserGuide_v1.3.pdf

