"""
This example code illustrates how to access and visualize a NSIDC MOD29
Level 2 HDF-EOS2 Swath file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MOD29.A2013196.1250.061.2021233075404.hdf.py

The HDF files must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2024-08-07
"""

import os

import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.basemap import Basemap
from pyhdf.SD import SD, SDC

FILE_NAME = "MOD29.A2013196.1250.061.2021233075404.hdf"
hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
DATAFIELD_NAME = "Ice_Surface_Temperature"
data2D = hdf.select(DATAFIELD_NAME)
data = data2D[:, :].astype(np.float64)

# Read attributes.
attrs = data2D.attributes(full=1)
aoa = attrs["add_offset"]
add_offset = aoa[0]
fva = attrs["_FillValue"]
_FillValue = fva[0]
sfa = attrs["scale_factor"]
scale_factor = sfa[0]
ua = attrs["units"]
units = ua[0]
va = attrs["valid_range"]
valid_range = va[0]
lna = attrs["long_name"]
long_name = lna[0]

# Read lat and lon data from the matching geo-location file.
GEO_FILE_NAME = "MOD03.A2013196.1250.061.2017299150213.hdf"
hdf_geo = SD(GEO_FILE_NAME, SDC.READ)

# Read geolocation dataset from MOD03 product.
lat = hdf_geo.select("Latitude")
latitude = lat[:, :]
lon = hdf_geo.select("Longitude")
longitude = lon[:, :]

# Apply the attributes.
invalid = np.logical_or(data < valid_range[0], data > valid_range[1])
invalid = np.logical_or(invalid, data == _FillValue)
data[invalid] = np.nan
data = data * scale_factor + add_offset
datam = np.ma.masked_array(data, mask=np.isnan(data))

# Draw a southern polar stereographic projection using the low resolution
# coastline database.
m = Basemap(projection="spstere", resolution="l", boundinglat=-64, lon_0=180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-80.0, -59, 10.0))
m.drawmeridians(
    np.arange(-180.0, 179.0, 30.0), labels=[True, False, False, True]
)
m.pcolormesh(longitude, latitude, datam, latlon=True)
cb = m.colorbar()
cb.set_label(units)

basename = os.path.basename(FILE_NAME)
plt.title("{0}\n{1}".format(basename, long_name))
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
