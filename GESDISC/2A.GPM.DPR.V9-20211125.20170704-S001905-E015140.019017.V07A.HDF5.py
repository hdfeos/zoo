"""
This example code illustrates how to access and visualize a GPM L2 HDF5 file
in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

  $python 2A.GPM.DPR.V9-20211125.20170704-S001905-E015140.019017.V07A.HDF5.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2021-07-27

"""

import os

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.basemap import Basemap

import h5py

# Reduce font size because file name is long.
mpl.rcParams.update({"font.size": 8})


file_name = "2A.GPM.DPR.V9-20211125.20170704-S001905-E015140.019017.V07A.HDF5"

with h5py.File(file_name, mode="r") as f:

    name = "/FS/SLV/precipRateESurface"
    data = f[name][:]
    units = f[name].attrs["units"].decode()
    _FillValue = f[name].attrs["_FillValue"]
    data[data == _FillValue] = np.nan
    data = np.ma.masked_where(np.isnan(data), data)

    # Get the geolocation data.
    latitude = f["/FS/Latitude"][:]
    longitude = f["/FS/Longitude"][:]

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
    m.scatter(
        longitude,
        latitude,
        c=data,
        s=1,
        cmap=plt.cm.jet,
        edgecolors=None,
        linewidth=0,
    )
    cb = m.colorbar(location="bottom", pad="10%")
    cb.set_label(units)

    basename = os.path.basename(file_name)
    plt.title("{0}\n{1}".format(basename, name))
    fig = plt.gcf()
    # plt.show()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
