"""

This example code illustrates how to access and visualize a GES DISC TROPICS06
Swath netCDF-4/HDF5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage: save this script and run

    $python TROPICS06.MIRS.L2B.Orbit04435.V02-06.ST20240224-162719.ET20240224-180211.CT20240325-020618.nc.py

Tested under: Python 3.9.13 :: Miniconda (x86_64)
Last Update: 2024-05-31
"""

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.basemap import Basemap
from netCDF4 import Dataset

# Open netCDF-4 file.
FILE_NAME = "TROPICS06.MIRS.L2B.Orbit04435.V02-06.ST20240224-162719.ET20240224-180211.CT20240325-020618.nc"
nc = Dataset(FILE_NAME)

# Read dataset.
DATAFIELD_NAME = "TPW"
dset = nc.variables[DATAFIELD_NAME]
data = dset[:]
units = dset.units
long_name = dset.long_name

latitude = nc.variables["Latitude"][:]
longitude = nc.variables["Longitude"][:]

m = Basemap(
    projection="cyl",
    resolution="l",
    llcrnrlat=-90,
    urcrnrlat=90,
    llcrnrlon=-180,
    urcrnrlon=180,
)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 45))
m.drawmeridians(np.arange(-180, 180, 45), labels=[True, False, False, True])
m.scatter(longitude, latitude, c=data, latlon=True)

cb = m.colorbar()
cb.set_label(units)

plt.title("{0}\n {1}".format(FILE_NAME, long_name), fontsize=8)
fig = plt.gcf()

pngfile = "{0}.py.png".format(FILE_NAME)
fig.savefig(pngfile)
