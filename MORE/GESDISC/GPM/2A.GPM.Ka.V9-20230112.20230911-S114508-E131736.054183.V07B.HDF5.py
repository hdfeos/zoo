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

   $python 2A.GPM.Ka.V9-20230112.20230911-S114508-E131736.054183.V07B.HDF5.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-10-02
"""

import os

import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.basemap import Basemap

import h5py

file_name = "2A.GPM.Ka.V9-20230112.20230911-S114508-E131736.054183.V07B.HDF5"

with h5py.File(file_name, mode="r") as f:
    name = "/FS/SLV/precipRateESurface"
    data = f[name][:]
    units = f[name].attrs["units"]
    _FillValue = f[name].attrs["_FillValue"]
    data[data == _FillValue] = np.nan
    data = np.ma.masked_where(np.isnan(data), data)

    # Get the geolocation data.
    latitude = f["/FS/Latitude"][:]
    longitude = f["/FS/Longitude"][:]

    # Subset India region.
    latbounds = [8.4, 37.6]
    lonbounds = [68.7, 97.25]

    # Subset region.
    s = (
        (latitude > latbounds[0])
        & (latitude < latbounds[1])
        & (longitude > lonbounds[0])
        & (longitude < lonbounds[1])
    )
    flag = not np.any(s)
    if flag:
        print("No data for the region.")

    datas = data[s]
    lons = longitude[s]
    lats = latitude[s]

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
    m.drawmeridians(
        np.arange(-180, 180, 45), labels=[True, False, False, True]
    )
    m.scatter(
        lons, lats, c=datas, s=1, cmap=plt.cm.jet, edgecolors=None, linewidth=0
    )
    cb = m.colorbar(location="bottom", pad="10%")
    units = units.decode("ascii", "replace")
    cb.set_label(units)

    basename = os.path.basename(file_name)
    plt.title("{0}\n{1}".format(basename, name))
    fig = plt.gcf()
    # plt.show()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
