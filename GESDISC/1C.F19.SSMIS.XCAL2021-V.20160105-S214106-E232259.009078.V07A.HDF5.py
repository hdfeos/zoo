"""
This example code illustrates how to access and visualize a GPM L1C HDF5 file
in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

  $python 1C.F19.SSMIS.XCAL2021-V.20160105-S214106-E232259.009078.V07A.HDF5.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2024-07-26

"""

import os

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.basemap import Basemap

import h5py

# Reduce font size because file name is long.
mpl.rcParams.update({"font.size": 9})

FILE_NAME = "1C.F19.SSMIS.XCAL2021-V.20160105-S214106-E232259.009078.V07A.HDF5"
with h5py.File(FILE_NAME, mode="r") as f:

    name = "/S1/Tc"
    data = f[name][:, :, 0]
    units = f[name].attrs["units"].decode()
    long_name = f[name].attrs["LongName"].decode()
    _FillValue = f[name].attrs["_FillValue"]
    data[data == _FillValue] = np.nan
    data = np.ma.masked_where(np.isnan(data), data)

    # Get the geolocation data
    latitude = f["/S1/Latitude"][:]
    longitude = f["/S1/Longitude"][:]

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

    basename = os.path.basename(FILE_NAME)
    plt.title("{0}\n{1}".format(basename, long_name + " (nchannel1=0)"))
    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
