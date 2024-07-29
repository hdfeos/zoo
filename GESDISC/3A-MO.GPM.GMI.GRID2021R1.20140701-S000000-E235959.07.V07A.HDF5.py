"""
This example code illustrates how to access and visualize a GPM L3 HDF5 file
in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python 3A-MO.GPM.GMI.GRID2021R1.20140701-S000000-E235959.07.V07A.HDF5.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2024-07-29
"""

import os

import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.basemap import Basemap

import h5py

FILE_NAME = "3A-MO.GPM.GMI.GRID2021R1.20140701-S000000-E235959.07.V07A.HDF5"

with h5py.File(FILE_NAME, mode="r") as f:

    name = "/Grid/cloudWater"
    data = f[name][0, :, :]
    units = f[name].attrs["units"].decode()
    _FillValue = f[name].attrs["_FillValue"]
    data[data == _FillValue] = np.nan
    data = np.ma.masked_where(np.isnan(data), data)

    # There is no geolocation data, so construct it ourselves.
    lon = np.arange(0.0, 1440.0) * 0.25 - 180 + 0.125
    lat = np.arange(0.0, 720.0) * 0.25 - 90 + 0.125

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
    m.pcolormesh(lon, lat, data.T, latlon=True)
    cb = m.colorbar()
    cb.set_label(units)

    basename = os.path.basename(FILE_NAME)
    plt.title("{0}\n{1}".format(basename, name))
    fig = plt.gcf()
    # plt.show()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
