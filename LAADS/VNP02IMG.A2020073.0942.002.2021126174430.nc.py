"""

This example code illustrates how to access and visualize a LAADS VNP02IMG 
netCDF-4/HDF5 Swath file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python VNP02IMG.A2020073.0942.002.2021126174430.nc.py

The netCDF-4/HDF5 data file and geolocation file [1] must be in your
current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2024-08-08
"""

import h5py
import os

import cartopy.crs as ccrs
import matplotlib.pyplot as plt
import numpy as np

from cartopy.mpl.gridliner import LATITUDE_FORMATTER, LONGITUDE_FORMATTER
from pyhdf.SD import SD, SDC

FILE_NAME = "VNP02IMG.A2020073.0942.002.2021126174430.nc"
GEO_FILE_NAME = "VNP03IMG.A2020073.0942.002.2021125004714.nc"
name = "/observation_data/I05"

with h5py.File(FILE_NAME, mode="r") as f:
    # Read dataset.
    data_raw = f[name][:]
    data = data_raw[:, :].astype(np.double)
    units = f[name].attrs['units']
    units = units.decode('ascii', 'replace')
    long_name = f[name].attrs['long_name']
    long_name = long_name.decode('ascii', 'replace')
    _FillValue = f[name].attrs['_FillValue']
    scale_factor = f[name].attrs['scale_factor']
    add_offset = f[name].attrs['add_offset']
    valid_max = f[name].attrs['valid_max']
    valid_min = f[name].attrs['valid_min']        
    invalid = np.logical_or(data > valid_max,
                            data < valid_min)
    invalid = np.logical_or(invalid, data == _FillValue)
    data[invalid] = np.nan
    data = np.ma.masked_where(np.isnan(data), data)
    data = scale_factor * data + add_offset
    
# Read lat/lon.
with h5py.File(GEO_FILE_NAME, mode="r") as f:
    # Get the geolocation data
    lat = f["/geolocation_data/latitude"][:]
    lon = f["/geolocation_data/longitude"][:]



# Find middle location.
lat_m = lat[int(lat.shape[0] / 2), int(lat.shape[1] / 2)]
lon_m = lon[int(lon.shape[0] / 2), int(lon.shape[1] / 2)]

# Let's use ortho projection.
orth = ccrs.Orthographic(
    central_longitude=lon_m, central_latitude=lat_m, globe=None
)
ax = plt.axes(projection=orth)

# Remove the following to see zoom-in view.
# ax.set_global()

# Plot on map.
p = plt.scatter(
    lon, lat, c=data, s=1, cmap=plt.cm.jet, transform=ccrs.PlateCarree()
)
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
plt.title("{0}\n{1}".format(basename, long_name), fontsize=8)
fig = plt.gcf()

# Save image.
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)

# References
# [1] https://cmr.earthdata.nasa.gov/search/concepts/C2105092163-LAADS.html
