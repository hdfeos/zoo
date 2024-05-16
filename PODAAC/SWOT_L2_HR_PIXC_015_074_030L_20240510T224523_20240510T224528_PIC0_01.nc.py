"""

This example code illustrates how to access and visualize a PO.DAAC
 SWOT L2 netCDF-4 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage: save this script and run

    $python SWOT_L2_HR_PIXC_015_074_030L_20240510T224523_20240510T224528_PIC0_01.nc.py

Tested under: Python 3.9.13 :: Miniconda (x86_64)
Last Update: 2024-05-15
"""

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.basemap import Basemap
from netCDF4 import Dataset

# Open netCDF-4 file.
FILE_NAME = "SWOT_L2_HR_PIXC_015_074_030L_20240510T224523_20240510T224528_PIC0_01.nc"
nc = Dataset(FILE_NAME)
g = nc.groups['pixel_cloud']

# Read dataset.
DATAFIELD_NAME = "water_frac"
dset = g.variables[DATAFIELD_NAME]
data = dset[:]
latitude = g.variables["latitude"][:]
longitude = g.variables["longitude"][:]

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
m.drawparallels(np.arange(latmin, latmax, 0.1), labels=[True, False, False, False])
m.drawmeridians(np.arange(lonmin, lonmax, 0.5), labels=[False, False, False, True])
m.scatter(longitude[::10], latitude[::10], c=data[::10], s=1, cmap=plt.cm.jet,
          edgecolors=None, linewidth=0)
cb = m.colorbar()
units = dset.units
cb.set_label("Unit: " + units)
long_name = dset.long_name
plt.title("{0}\n {1}".format(FILE_NAME, long_name), fontsize=8)
fig = plt.gcf()

# Save plot.
pngfile = "{0}.py.png".format(FILE_NAME)
fig.savefig(pngfile)
