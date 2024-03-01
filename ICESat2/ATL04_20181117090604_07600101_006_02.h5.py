"""

This example code illustrates how to access and visualize an NSIDC
ICESat-2 ATL04 L2A version 6 HDF5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

   $python ATL04_20181117090604_07600101_006_02.h5.py

The HDF5 file must in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2024-03-01
"""

import os

import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.basemap import Basemap

import h5py

FILE_NAME = "ATL04_20181117090604_07600101_006_02.h5"
with h5py.File(FILE_NAME, mode="r") as f:

    # Ground Track L1
    latvar = f["/profile_1/latitude"]
    latitude = latvar[:]
    lat_vr = [latvar.attrs["valid_min"], latvar.attrs["valid_max"]]

    lonvar = f["/profile_1/longitude"]
    longitude = lonvar[:]
    lon_vr = [lonvar.attrs["valid_min"], lonvar.attrs["valid_max"]]

    # We'll plot height.
    tempvar = f["/profile_1/dem_h"]
    temp = tempvar[:]
    units = tempvar.attrs["units"]
    units = units.decode("ascii", "replace")
    long_name = tempvar.attrs["long_name"]
    long_name = long_name.decode("ascii", "replace")

    # Draw an equidistant cylindrical projection using the low resolution
    # coastline database.
    m = Basemap(
        projection="cyl",
        resolution="l",
        llcrnrlat=-90,
        urcrnrlat=90,
        llcrnrlon=-180,
        urcrnrlon=180,
    )
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90.0, 120.0, 30.0))
    m.drawmeridians(np.arange(-180, 180.0, 45.0))
    m.scatter(
        longitude,
        latitude,
        c=temp,
        s=1,
        cmap=plt.cm.jet,
        edgecolors=None,
        linewidth=0,
    )
    cb = m.colorbar()
    cb.set_label(units)
    basename = os.path.basename(FILE_NAME)
    plt.title("{0}\n{1}".format(basename, long_name))

    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
