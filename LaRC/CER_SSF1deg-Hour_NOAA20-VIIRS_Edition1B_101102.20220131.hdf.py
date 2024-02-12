"""

This example code illustrates how to access and visualize a LaRC CERES SSF
NOAA20 VIIRS HDF4 L3 Hourly file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python CER_SSF1deg-Hour_NOAA20-VIIRS_Edition1B_101102.20220131.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2022-10-26
"""

import os

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from pyhdf.SD import SD, SDC
from mpl_toolkits.basemap import Basemap

FILE_NAME = 'CER_SSF1deg-Hour_NOAA20-VIIRS_Edition1B_101102.20220131.hdf'
hdf = SD(FILE_NAME, SDC.READ)
# Print available datasets.
# print(hdf.datasets())

# Read dataset.
DATAFIELD_NAME = 'clr_toa_lw'
dset = hdf.select(DATAFIELD_NAME)
data3D = dset[:].astype(np.double)
data = data3D[0,:,:]

# Read attributes.
attrs = dset.attributes(full=1)
ua=attrs["units"]
units = ua[0]
fva=attrs["_FillValue"]
fillvalue = fva[0]
la=attrs["long_name"]
long_name = la[0]

# Read geolocation datasets.
lat = hdf.select('latitude')
latitude = lat[:]
lon = hdf.select('longitude')
longitude = lon[:]

# Read time index dataset.
ind = hdf.select('gmt_hour_index')
index = ind[:]

# Read attributes.
attrs = ind.attributes(full=1)
la=attrs["long_name"]
long_name_index = la[0]

# Apply the fill value attribute.
data[data == fillvalue] = np.nan
data = np.ma.masked_array(data, np.isnan(data))

# Set title.

title = long_name + ' at ' + long_name_index + ' = ' + str(index[0])
m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon=180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 30), labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(-180, 181, 45), labels=[0, 0, 0, 1])
m.pcolormesh(longitude, latitude, data, latlon=True, shading='auto')
cb = m.colorbar()
cb.set_label(units)
basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, title), fontsize=8)
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
