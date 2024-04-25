"""
This example code illustrates how to access and visualize a GESDISC AIRS L2
swath in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python AIRS.2023.07.08.071.L2.RetStd_IR.v7.0.7.0.G23189145810.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2024-04-25
"""

import os

import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.basemap import Basemap
from pyhdf.SD import SD, SDC

FILE_NAME = "AIRS.2023.07.08.071.L2.RetStd_IR.v7.0.7.0.G23189145810.hdf"
DATAFIELD_NAME = "TAirStd"

hdf = SD(FILE_NAME, SDC.READ)
# List available SDS datasets.
# print(hdf.datasets())

# Read dataset.
data3D = hdf.select(DATAFIELD_NAME)
# lev = 0 has mostly fill value. Try 15.
lev = 15
data = data3D[:, :, lev]

# Read geolocation dataset.
lat = hdf.select("Latitude")
latitude = lat[:, :]
lon = hdf.select("Longitude")
longitude = lon[:, :]

# Check lat/lon/data values.
# print(latitude)
# print(longitude)
# print(data)

# Handle fill value.
attrs = data3D.attributes(full=1)
# print(attrs)
fillvalue = attrs["_FillValue"]

# fillvalue[0] is the attribute value.
fv = fillvalue[0]
data[data == fv] = np.nan
data = np.ma.masked_array(data, np.isnan(data))

m = Basemap(
    projection="cyl",
    resolution="l",
    llcrnrlat=-90,
    urcrnrlat=90,
    llcrnrlon=-180,
    urcrnrlon=180,
)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 90, 30), labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(-180, 180, 30), labels=[0, 0, 0, 1])
sc = m.scatter(
    longitude,
    latitude,
    c=data,
    s=0.1,
    cmap=plt.cm.jet,
    edgecolors=None,
    linewidth=0,
)

cb = m.colorbar()
cb.set_label("K")
basename = os.path.basename(FILE_NAME)
plt.title(
    "{0}\n {1} at StdPressureLev={2}".format(basename, DATAFIELD_NAME, lev)
)
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
