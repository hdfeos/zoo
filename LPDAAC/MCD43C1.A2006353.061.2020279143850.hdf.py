"""
This example code illustrates how to access and visualize an LP DAAC MCD43C1
 HDF-EOS2 Grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MCD43C1.A2006353.061.2020279143850.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2024-11-07
"""

import os
import re

import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.basemap import Basemap
from pyhdf.SD import SD, SDC

FILE_NAME = "MCD43C1.A2006353.061.2020279143850.hdf"

# Identify the data field.
DATAFIELD_NAME = "Percent_Snow"

hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data2D = hdf.select(DATAFIELD_NAME)
data = data2D[:, :].astype(np.double)

# Read attributes.
attrs = data2D.attributes(full=1)
lna = attrs["long_name"]
long_name = lna[0]
vra = attrs["valid_range"]
valid_range = vra[0]
fva = attrs["_FillValue"]
_FillValue = fva[0]
ua = attrs["units"]
units = ua[0]

# Handle fill value.
invalid = data == _FillValue
invalid = np.logical_or(invalid, data < valid_range[0])
invalid = np.logical_or(invalid, data > valid_range[1])
data[invalid] = np.nan

# Construct the grid.  The needed information is in a global attribute
# called 'StructMetadata.0'.  Use regular expressions to tease out the
# extents of the grid.  In addition, the grid is in packed decimal
# degrees, so we need to normalize to degrees.
fattrs = hdf.attributes(full=1)
ga = fattrs["StructMetadata.0"]
gridmeta = ga[0]

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
x = np.linspace(x0, x1, nx)
y = np.linspace(y0, y1, ny)
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
m.drawparallels(np.arange(-90, 90, 45), labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(-180, 181, 45), labels=[0, 0, 0, 1])
m.pcolormesh(lon, lat, data)

cb = m.colorbar()
cb.set_label(units)

basename = os.path.basename(FILE_NAME)
plt.title("{0}\n{1}".format(basename, long_name))

fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
