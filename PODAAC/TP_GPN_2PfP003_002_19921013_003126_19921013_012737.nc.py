"""

This example code illustrates how to access and visualize a PO.DAAC
 TOPEX_POSEIDON_GDR_F L2 netCDF-4 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage: save this script and run

    $python TP_GPN_2PfP003_002_19921013_003126_19921013_012737.nc.py

Tested under: Python 3.9.13 :: Miniconda (x86_64)
Last Update: 2023-11-09
"""

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.basemap import Basemap
from netCDF4 import Dataset

# Open netCDF-4 file.
FILE_NAME = "TP_GPN_2PfP003_002_19921013_003126_19921013_012737.nc"
nc = Dataset(FILE_NAME)

# Read dataset.
DATAFIELD_NAME = "swh_ku"
dset = nc.variables[DATAFIELD_NAME]
data = dset[:]
latitude = nc.variables["latitude"][:]
longitude = nc.variables["longitude"][:]

print(longitude)
latmin = np.min(latitude)
latmax = np.max(latitude)
lonmin = np.min(longitude)
lonmax = np.max(longitude)

m = Basemap(
    projection="cyl",
    resolution="l",
    llcrnrlat=latmin, urcrnrlat = latmax,
    llcrnrlon=lonmin, urcrnrlon = lonmax
)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 45), labels=[True, False, False, False])
m.drawmeridians(np.arange(-180, 180, 45), labels=[False, False, False, True])
m.scatter(longitude, latitude, c=data, s=10, cmap=plt.cm.jet,
          edgecolors=None, linewidth=0)
cb = m.colorbar()
units = dset.units
cb.set_label("Unit: " + units)
long_name = dset.long_name
plt.title("{0}\n {1}".format(FILE_NAME, long_name))
fig = plt.gcf()

# Save plot.
pngfile = "{0}.py.png".format(FILE_NAME)
fig.savefig(pngfile)
