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

   $python 2A23.20150401.98981.7.HDF.s.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-09-07
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

DATAFIELD_NAME = "freezH"
ds = hdf.select(DATAFIELD_NAME)
data = ds[:, :].astype(np.double)

# Retrieve the geolocation data.
lat = hdf.select("Latitude")
latitude = lat[:, :]
lon = hdf.select("Longitude")
longitude = lon[:, :]

# Read attributes.
attrs = ds.attributes(full=1)
ua = attrs["units"]
units = ua[0]

# Handle fill value
fillvalue = -9999.0
data[data == fillvalue] = np.nan
data = np.ma.masked_array(data, np.isnan(data))

# There is a wrap-around effect to deal with.
# Adjust the longitude by modulus 360 to avoid the swath being smeared.
longitude[longitude < -165] += 360

# Subset 'South Africa'
# (16.3449768409, -34.8191663551, 32.830120477, -22.0913127581)
latbounds = [-34.8191663551, -22.0913127581]
lonbounds = [16.3449768409, 32.830120477]


# Subset region.
s = ((latitude > latbounds[0]) & (latitude < latbounds[1]) &
     (longitude > lonbounds[0]) & (longitude < lonbounds[1]))
flag = not np.any(s)
if flag:
    print('No data for the region.')

datas = data[s]
lons = longitude[s]
lats = latitude[s]

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
sc = m.scatter(lons, lats, c=datas, s=0.1, cmap=plt.cm.jet,
                edgecolors=None, linewidth=0)

cb = m.colorbar()
cb.set_label(units)

basename = os.path.basename(FILE_NAME)
plt.title("{0}\n{1}".format(basename, DATAFIELD_NAME))

fig = plt.gcf()
pngfile = "{0}.s.py.png".format(basename)
fig.savefig(pngfile)
