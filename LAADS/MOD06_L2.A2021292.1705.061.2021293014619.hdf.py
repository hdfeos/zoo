"""
This example code illustrates how to access and visualize a LAADS MODIS swath
file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MOD06_L2.A2021292.1705.061.2021293014619.hdf.py

The HDF files must be in your current working directory.

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2024-01-23
"""
import os

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np

from matplotlib import colors
from mpl_toolkits.basemap import Basemap
from pyhdf.SD import SD, SDC

FILE_NAME = "MOD06_L2.A2021292.1705.061.2021293014619.hdf"
GEO_FILE_NAME = "MOD03.A2021292.1705.061.2021292234719.hdf"
DATAFIELD_NAME = "Cloud_Phase_Infrared_1km"

hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data2D = hdf.select(DATAFIELD_NAME)
data = data2D[:, :].astype(np.double)

hdf_geo = SD(GEO_FILE_NAME, SDC.READ)

# Read geolocation dataset from MOD03 product.
lat = hdf_geo.select("Latitude")
latitude = lat[:, :]
lon = hdf_geo.select("Longitude")
longitude = lon[:, :]

# Retrieve attributes.
attrs = data2D.attributes(full=1)
lna = attrs["long_name"]
long_name = lna[0]
aoa = attrs["add_offset"]
add_offset = aoa[0]
fva = attrs["_FillValue"]
_FillValue = fva[0]
sfa = attrs["scale_factor"]
scale_factor = sfa[0]
vra = attrs["valid_range"]
valid_min = vra[0][0]
valid_max = vra[0][1]
ua = attrs["units"]
units = ua[0]

invalid = np.logical_or(data > valid_max, data < valid_min)
invalid = np.logical_or(invalid, data == _FillValue)
data[invalid] = np.nan
data = (data - add_offset) * scale_factor
data = np.ma.masked_array(data, np.isnan(data))
# Find middle location.
lat_m = np.nanmean(latitude)
lon_m = np.nanmean(longitude)

# Make a color map of fixed colors.
cmap = colors.ListedColormap(
    ["black", "blue", "yellow", "green", "red", "purple", "gray"]
)

# Define the bins and normalize.
bounds = np.linspace(0, 7, 8)
norm = mpl.colors.BoundaryNorm(bounds, cmap.N)


# Render the plot in a lambert equal area projection.
m = Basemap(
    projection="laea",
    resolution="l",
    lat_ts=65,
    lat_0=lat_m,
    lon_0=lon_m,
    width=3000000,
    height=2500000,
)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90.0, 90.0, 10.0), labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(-180, 180.0, 10.0), labels=[0, 0, 0, 1])
m.pcolormesh(longitude, latitude, data, latlon=True, cmap=cmap)

basename = os.path.basename(FILE_NAME)

# Split display of long name.
plt.title(
    "{0}\n{1}\n{2}".format(basename, long_name[0:80], long_name[80:]),
    fontsize=8,
)
fig = plt.gcf()

# Create a second axes for the colorbar.
ax2 = fig.add_axes([0.88, 0.2, 0.01, 0.6])
cb = mpl.colorbar.ColorbarBase(
    ax2,
    cmap=cmap,
    norm=norm,
    spacing="proportional",
    ticks=bounds,
    boundaries=bounds,
    format="%1i",
)
loc = bounds + 0.5
cb.set_ticks(loc[:-1])
cb.ax.set_yticklabels(
    [
        "cloud free",
        "water cloud",
        "ice cloud",
        "mixed phase\ncloud",
        "",
        "",
        "undetermined\nphase",
    ],
    fontsize=5,
)

pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
