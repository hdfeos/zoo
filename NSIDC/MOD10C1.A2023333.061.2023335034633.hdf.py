"""
This example code illustrates how to access and visualize a NSIDC
MOD10C1 HDF-EOS2 Grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MOD10C1.A2023333.061.2023335034633.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2023-12-01
"""

import os
import re

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.basemap import Basemap
from pyhdf.SD import SD, SDC

FILE_NAME = "MOD10C1.A2023333.061.2023335034633.hdf"
DATAFIELD_NAME = "Day_CMG_Snow_Cover"

hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data2D = hdf.select(DATAFIELD_NAME)
data = data2D[:, :].astype(np.float64)

# Read attributes.
attrs = data2D.attributes(full=1)
ln = attrs["long_name"]
long_name = ln[0]

# Read global attribute.
fattrs = hdf.attributes(full=1)
ga = fattrs["StructMetadata.0"]
gridmeta = ga[0]

# Read projection parameters.
# The needed information is in a global attribute called 'StructMetadata.0'.
# Use regular expressions to tease out the extents of the grid.
ul_regex = re.compile(
    r"""UpperLeftPointMtrs=\(
(?P<upper_left_x>[+-]?\d+\.\d+)
,
(?P<upper_left_y>[+-]?\d+\.\d+)
\)""",
    re.VERBOSE,
)
match = ul_regex.search(gridmeta)

x0 = np.float64(match.group("upper_left_x")) / 1e6
y0 = np.float64(match.group("upper_left_y")) / 1e6

lr_regex = re.compile(
    r"""LowerRightMtrs=\(
(?P<lower_right_x>[+-]?\d+\.\d+)
,
(?P<lower_right_y>[+-]?\d+\.\d+)
\)""",
    re.VERBOSE,
)
match = lr_regex.search(gridmeta)
x1 = np.float64(match.group("lower_right_x")) / 1e6
y1 = np.float64(match.group("lower_right_y")) / 1e6
ny, nx = data.shape
xinc = (x1 - x0) / nx
yinc = (y1 - y0) / ny

# Construct the grid.  It's already in lat/lon.
x = np.linspace(x0, x0 + xinc * nx, nx)
y = np.linspace(y0, y0 + yinc * ny, ny)
lon, lat = np.meshgrid(x, y)

m = Basemap(
    projection="cyl",
    resolution="l",
    llcrnrlat=-90,
    urcrnrlat=90,
    llcrnrlon=-180,
    urcrnrlon=180,
)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90.0, 120.0, 30.0), labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(-180, 180.0, 45.0), labels=[0, 0, 0, 1])

# Bin the data as follows:
# 0% snow
# 1-99% snow
# 100% snow
# lake ice (107)
# night (111)
# inland water (237)
# ocean (239)
# cloud-obscured water (250)
# data not mapped (253)
# fill (255)
lst = [
    "#00ff00",  # 0% snow
    "#888888",  # 1-99% snow
    "#ffffff",  # 100% snow
    "#ffafff",  # lake ice
    "#000000",  # night
    "#0000cc",  # inland water
    "#0000dd",  # ocean
    "#63c6ff",  # cloud-obscured water
    "#00ffcc",  # data not mapped
    "#8928dd",
]  # fill
cmap = mpl.colors.ListedColormap(lst)
bounds = [0, 1, 100, 107, 111, 237, 239, 250, 253, 255, 256]
norm = mpl.colors.BoundaryNorm(bounds, cmap.N)

m.pcolormesh(
    lon[::2, ::2],
    lat[::2, ::2],
    data[::2, ::2],
    latlon=True,
    cmap=cmap,
    norm=norm,
)

basename = os.path.basename(FILE_NAME)
plt.title("{0}\n{1}".format(basename, long_name))

cb = plt.colorbar(orientation="horizontal")
labels = [
    "0%\nsnow",
    "1-99%\nsnow",
    "100%\nsnow",
    "lake\nice",
    "night",
    "inland\nwater",
    "ocean",
    "cloud\n-obscured\nwater",
    "data\nnot\nmapped",
    "fill",
]
ticks = [0.5, 50, 103, 109, 180, 237.8, 242, 251.5, 254.5, 255.5]
cb.set_ticks(ticks=ticks, labels=labels)

pngfile = "{0}.py.png".format(basename)

fig = plt.gcf()
fig.savefig(pngfile)
