"""

This example code illustrates how to access and visualize a LaRC CERES BDS NPP
HDF4 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python CER_BDS_NPP-FM5_Edition2_200211.20220201.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2022-07-28
"""

import os

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from pyhdf.SD import SD, SDC
from mpl_toolkits.basemap import Basemap

FILE_NAME = 'CER_BDS_NPP-FM5_Edition2_200211.20220201.hdf'
DATAFIELD_NAME = 'Total Detector Output'

hdf = SD(FILE_NAME, SDC.READ)

# Print available datasets.
# print(hdf.datasets())

# Read dataset.
dset = hdf.select(DATAFIELD_NAME)
data = dset[:].astype(np.double)

# Read geolocation datasets.
lat = hdf.select('Colatitude of CERES FOV at Surface')
latitude = lat[:]
lon = hdf.select('Longitude of CERES FOV at Surface')
longitude = lon[:]

# Read attributes.
attrs = dset.attributes(full=1)
ua=attrs["units"]
units = ua[0]
fva=attrs["_FillValue"]
fillvalue = fva[0]

# Apply the fill value attribute.
data[data == fillvalue] = np.nan
data = np.ma.masked_array(data, np.isnan(data))

# Adjust lat/lon values.
latitude = 90 - latitude
longitude[longitude>180]=longitude[longitude>180]-360;

# Subset valid data.
idx = np.where((latitude>= -90.0) & (latitude<=90.0))

# The data is global, so render in a global projection.
m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon=180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 30), labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(-180, 181, 45), labels=[0, 0, 0, 1])
sc = m.scatter(longitude[idx], latitude[idx], c=data[idx], s=1,
               cmap=plt.cm.jet,
               edgecolors=None, linewidth=0)
cb = m.colorbar()
cb.set_label(units)

basename = os.path.basename(FILE_NAME)
long_name = DATAFIELD_NAME
plt.title('{0}\n{1}'.format(basename, long_name))
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
    
