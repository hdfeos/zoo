"""
This example code illustrates how to access and visualize a GESDISC TRMM 2A23
version 7 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

   $python 2A23.20150401.98981.7.HDF.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-09-06
"""
import os

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.axes_grid1 import make_axes_locatable
from mpl_toolkits.basemap import Basemap
from pyhdf.SD import SD, SDC

FILE_NAME = "2A23.20150401.98981.7.HDF"
hdf = SD(FILE_NAME, SDC.READ)

DATAFIELD_NAME = "rainType"
ds = hdf.select(DATAFIELD_NAME)
data = ds[:, :].astype(np.double)

# Retrieve the geolocation data.
lat = hdf.select("Latitude")
latitude = lat[:, :]
lon = hdf.select("Longitude")
longitude = lon[:, :]

# Construct an indexed version of the data. See page 81 of [1].
levels = [-88.0, 100.0, 200.0, 300.0]
Z = np.zeros(data.shape, dtype=np.float64)
for j in range(len(levels) - 1):
    Z[np.logical_and(data >= levels[j], data < levels[j + 1])] = j
Z[data >= levels[-1]] = len(levels) - 1

# There is a wrap-around effect to deal with.  Adjust the longitude by
# modulus 360 to avoid the swath being smeared.
longitude[longitude < -165] += 360

# Draw an equidistant cylindrical projection using the low resolution
# coastline database.
m = Basemap(
    projection="cyl",
    resolution="l",
    llcrnrlat=-90,
    urcrnrlat=90,
    llcrnrlon=-165,
    urcrnrlon=197,
)

m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90.0, 120.0, 30.0), labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(-180, 180.0, 45.0), labels=[0, 0, 0, 1])

# Use a discretized colormap since we have only 4 levels.
colors = ["#ffffff", "#0000ff", "#00ff00", "#aaaaaa"]
cmap = mpl.colors.ListedColormap(colors)
bounds = np.linspace(0, 4, 5)
norm = mpl.colors.BoundaryNorm(bounds, cmap.N)
m.pcolormesh(longitude, latitude, Z, latlon=True, cmap=cmap, norm=norm)
basename = os.path.basename(FILE_NAME)
plt.title("{0}\n{1}".format(basename, DATAFIELD_NAME))

# Adjust colorbar height.
divider = make_axes_locatable(plt.gca())
cax = divider.append_axes("right", "5%", pad="3%")
cb = plt.colorbar(cax=cax)
loc = bounds + 0.5
cb.set_ticks(loc[:-1])
cb.set_ticklabels(["missing", "strati.", "convec.", "other"])

fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)

# Reference
# [1] https://www.eorc.jaxa.jp/TRMM/documents/PR_algorithm_product_information/pr_manual/PR_Instruction_Manual_V7_L1.pdf
