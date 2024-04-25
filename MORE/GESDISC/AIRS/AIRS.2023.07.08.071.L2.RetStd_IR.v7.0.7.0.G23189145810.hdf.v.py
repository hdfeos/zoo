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

    $python AIRS.2023.07.08.071.L2.RetStd_IR.v7.0.7.0.G23189145810.hdf.v.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2024-04-25
"""

import os

import matplotlib.pyplot as plt
import numpy as np
from pyhdf.SD import SD, SDC

FILE_NAME = "AIRS.2023.07.08.071.L2.RetStd_IR.v7.0.7.0.G23189145810.hdf"
DATAFIELD_NAME = "TAirStd"

hdf = SD(FILE_NAME, SDC.READ)
# List available SDS datasets.
# print(hdf.datasets())

# Read dataset.
data3D = hdf.select(DATAFIELD_NAME)
data = data3D[:, :, :]

# Read geolocation dataset.
lat = hdf.select("Latitude")
latitude = lat[:, :]
lon = hdf.select("Longitude")
longitude = lon[:, :]
lev = hdf.select("StdPressureLev:L2_Standard_atmospheric&surface_product")
pressure = lev[:]
# print(pressure)
pattrs = lev.attributes(full=1)
pres_long_name = pattrs["long_name"][0]
pres_units = pattrs["units"][0]

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

# Subset a point near Ecuador [1].
# Change values if there's no matching data.
# lon = 77.5 : 77.0 W
# lat = 0.2 : 0.1 S

lonbounds = [-77.5, -77.0]
latbounds = [-0.2, -0.1]

# latitude lower and upper index
mask = (
    (latitude > latbounds[0])
    & (latitude < latbounds[1])
    & (longitude > lonbounds[0])
    & (longitude < lonbounds[1])
)
lats = latitude[mask]
# print(lats)
lons = longitude[mask]
# print(lons)
datas = data[mask, :]
# print(datas[0])

basename = os.path.basename(FILE_NAME)
plt.plot(datas[0], pressure)
plt.ylabel("{0} ({1})".format(pres_long_name, pres_units))
plt.xlabel("{0} ({1})".format(DATAFIELD_NAME, "K"))
plt.title(
    "{0}\n {1} at lon={2} & lat={3}".format(
        basename, DATAFIELD_NAME, lons[0], lats[0]
    )
)
# This is useful for putting high pressure at the bottom.
plt.gca().invert_yaxis()

# Use log scale.
plt.gca().set_yscale("log")

fig = plt.gcf()
pngfile = "{0}.v.py.png".format(basename)
fig.savefig(pngfile)

# Reference
# [1] https://www.mapsofworld.com/lat_long/ecuador-lat-long.html
