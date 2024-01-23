"""
This example code illustrates how to access and visualize a LaRC CALIPSO file
in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python CAL_LID_L2_VFM-Standard-V4-51.2019-07-12T04-47-04ZD.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2024-01-22
"""

import os

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import colors
from mpl_toolkits.basemap import Basemap
from pyhdf.SD import SD, SDC

FILE_NAME = "CAL_LID_L2_VFM-Standard-V4-51.2019-07-12T04-47-04ZD.hdf"
DATAFIELD_NAME = "Feature_Classification_Flags"

hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data2D = hdf.select(DATAFIELD_NAME)
data = data2D[:, 1256]

# Read geolocation datasets.
latitude = hdf.select("Latitude")
lat = latitude[:]
longitude = hdf.select("Longitude")
lon = longitude[:]

# Subset data. Otherwise, all points look black.
lat = lat[::10]
lon = lon[::10]
data = data[::10]

# Extract Feature Type only through bitmask.
data = data & 7

# Make a color map of fixed colors.
cmap = colors.ListedColormap(
    ["black", "blue", "yellow", "green", "red", "purple", "gray", "white"]
)
# The data is global, so render in a global projection.
m = Basemap(
    projection="cyl",
    resolution="l",
    llcrnrlat=-90,
    urcrnrlat=90,
    llcrnrlon=-180,
    urcrnrlon=180,
)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90.0, 90, 45), labels=[True, False, False, False])
m.drawmeridians(np.arange(-180.0, 180, 45), labels=[False, False, False, True])
x, y = m(lon, lat)
i = 0
for feature in data:
    m.plot(x[i], y[i], "o", color=cmap(feature), markersize=3)
    i = i + 1


long_name = "Feature Type at Altitude = 2500m"
basename = os.path.basename(FILE_NAME)
plt.title("{0}\n{1}".format(basename, long_name))

fig = plt.gcf()

# Deefine the bins and normalize.
bounds = np.linspace(0, 8, 9)
norm = mpl.colors.BoundaryNorm(bounds, cmap.N)

# Create a second axes for the colorbar.
ax2 = fig.add_axes([0.92, 0.2, 0.01, 0.6])
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
        "invalid",
        "clear",
        "cloud",
        "aerosol",
        "strato",
        "surface",
        "subsurf",
        "no signal",
    ],
    fontsize=5,
)

pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
