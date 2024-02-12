"""

This example code illustrates how to access and visualize a LaRC MISR EBAF
AS AEROSOL netCDF-4 grid product in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MISR_AM1_AS_AEROSOL_P142_O117590_F13_0023.nc.py

The netCDF-4 file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-10-25

"""

import os

import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.basemap import Basemap

import h5py

# Open file.
FILE_NAME = "MISR_AM1_AS_AEROSOL_P142_O117590_F13_0023.nc"
with h5py.File(FILE_NAME, mode="r") as f:
    # Read data.
    var = f["/4.4_KM_PRODUCTS/Aerosol_Optical_Depth"]
    data = var[:]

    lat = f["/4.4_KM_PRODUCTS/Latitude"][:]
    lon = f["/4.4_KM_PRODUCTS/Longitude"][:]

    # Read attributes.
    units = var.attrs["units"].decode()
    long_name = var.attrs["long_name"].decode()

    # Handle fill value.
    fillvalue = var.attrs["_FillValue"]
    data[data == fillvalue] = np.nan
    data = np.ma.masked_array(data, np.isnan(data))

    # Plot data.
    m = Basemap(
        projection="cyl",
        resolution="l",
        llcrnrlat=-90,
        urcrnrlat=90,
        llcrnrlon=-180,
        urcrnrlon=180,
    )
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90, 91, 30), labels=[1, 0, 0, 0])
    m.drawmeridians(np.arange(-180, 181, 45), labels=[0, 0, 0, 1])
    m.scatter(
        lon, lat, c=data, s=0.1, cmap=plt.cm.jet, edgecolors=None, linewidth=0
    )
    cb = m.colorbar()
    cb.set_label(units)

    basename = os.path.basename(FILE_NAME)
    plt.title("{0}\n{1}".format(basename, long_name), fontsize=8)
    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
