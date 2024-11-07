"""
This example code illustrates how to access and visualize an LP DAAC MCD43A3
sinusoidal grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage: save this script and run

    $python MCD43A3.A2013305.h12v11.061.2021242063456.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2024-11-06
"""

import os
import re

import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.basemap import Basemap
from pyhdf.SD import SD, SDC
from pyproj import Transformer

FILE_NAME = "MCD43A3.A2013305.h12v11.061.2021242063456.hdf"
hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
DATAFIELD_NAME = "Albedo_BSA_Band1"
data2D = hdf.select(DATAFIELD_NAME)
data = data2D[:, :].astype(np.float64)

# Read global attribute.
fattrs = hdf.attributes(full=1)
ga = fattrs["StructMetadata.0"]
gridmeta = ga[0]

# Construct the grid.  The needed information is in a global attribute
# called 'StructMetadata.0'.  Use regular expressions to tease out the
# extents of the grid.
ul_regex = re.compile(
    r"""UpperLeftPointMtrs=\(
(?P<upper_left_x>[+-]?\d+\.\d+)
,
(?P<upper_left_y>[+-]?\d+\.\d+)
\)""",
    re.VERBOSE,
)
match = ul_regex.search(gridmeta)
x0 = float(match.group("upper_left_x"))
y0 = float(match.group("upper_left_y"))

lr_regex = re.compile(
    r"""LowerRightMtrs=\(
(?P<lower_right_x>[+-]?\d+\.\d+)
,
(?P<lower_right_y>[+-]?\d+\.\d+)
\)""",
    re.VERBOSE,
)
match = lr_regex.search(gridmeta)
x1 = float(match.group("lower_right_x"))
y1 = float(match.group("lower_right_y"))
ny, nx = data.shape
xinc = (x1 - x0) / nx
yinc = (y1 - y0) / ny


x = np.linspace(x0, x0 + xinc * nx, nx)
y = np.linspace(y0, y0 + yinc * ny, ny)
xv, yv = np.meshgrid(x, y)

sinu = "+proj=sinu +R=6371007.181 +nadgrids=@null +wktext"
t = Transformer.from_crs(sinu, "epsg:4326", always_xy=True)
lon, lat = t.transform(xv, yv)

# Get lat/lon min/max for zoomed image.
latmin = np.min(lat) - 10
latmax = np.max(lat) + 10
lonmin = np.min(lon) - 5
lonmax = np.max(lon) + 5
lon0 = (lonmax + lonmin) / 2.0

# Read attributes.
attrs = data2D.attributes(full=1)
lna = attrs["long_name"]
long_name = lna[0]
vra = attrs["valid_range"]
valid_range = vra[0]
aoa = attrs["add_offset"]
add_offset = aoa[0]
fva = attrs["_FillValue"]
_FillValue = fva[0]
sfa = attrs["scale_factor"]
scale_factor = sfa[0]
ua = attrs["units"]
units = ua[0]


invalid = data == _FillValue
invalid = np.logical_or(invalid, data < valid_range[0])
invalid = np.logical_or(invalid, data > valid_range[1])
data[invalid] = np.nan
data = scale_factor * (data - add_offset)
data = np.ma.masked_array(data, np.isnan(data))


m = Basemap(
    projection="cyl",
    resolution="l",
    lon_0=-10,
    llcrnrlat=-32.5,
    urcrnrlat=-17.5,
    llcrnrlon=-72.5,
    urcrnrlon=-52.5,
)
m.drawcoastlines(linewidth=1.0)
m.drawparallels(np.arange(-30, -10, 5), labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(-70, -50, 5), labels=[0, 0, 0, 1])
m.pcolormesh(lon, lat, data)
# Subset if you want to speed up processing.
# m.pcolormesh(lon[::2], lat[::2], data[::2])

cb = m.colorbar()
cb.set_label(units)

basename = os.path.basename(FILE_NAME)
plt.title("{0}\n{1}\n".format(basename, long_name), fontsize=11)

fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
