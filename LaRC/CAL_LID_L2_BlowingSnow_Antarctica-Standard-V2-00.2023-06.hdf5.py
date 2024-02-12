"""

This example code illustrates how to access and visualize a LaRC ASDC
CALIPSO L2 HDF5 Swath file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage: save this script and run

    $python CAL_LID_L2_BlowingSnow_Antarctica-Standard-V2-00.2023-06.hdf5.py


The HDF-EOS file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2024-02-08
"""

import h5py
import os

import cartopy.crs as ccrs
import matplotlib.pyplot as plt
import numpy as np

from cartopy.mpl.gridliner import LATITUDE_FORMATTER, LONGITUDE_FORMATTER

# Open file.
FILE_NAME = "CAL_LID_L2_BlowingSnow_Antarctica-Standard-V2-00.2023-06.hdf5"
with h5py.File(FILE_NAME, mode="r") as f:
    # Read data.
    name = "/Snow_Fields/Blowing_Snow_Depol_Profile"
    data = f[name][:].astype(np.float64)
    data = data[:, 0]

    # Read attributes.
    units = f[name].attrs["units"].decode()

    # Set attribute.
    long_name = "Blowing_Snow_Depol_Profile"

    # Get the geolocation data
    lat = f["/Geolocation_Fields/Latitude"][:]
    lon = f["/Geolocation_Fields/Longitude"][:]

# Handle FillValue
_FillValue = 0.0
data[data == _FillValue] = np.nan
data = np.ma.masked_where(np.isnan(data), data)

# Use ortho projection.
orth = ccrs.Orthographic(central_longitude=0, central_latitude=-90, globe=None)
ax = plt.axes(projection=orth)

# Plot on map.
p = plt.scatter(
    lon, lat, c=data, s=0.1, cmap=plt.cm.jet, transform=ccrs.PlateCarree()
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

plt.title("{0}\n{1}".format(basename, long_name), fontsize=12)
fig = plt.gcf()

# Save image.
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
