"""
This example code illustrates how to access and visualize a LP DAAC
ECOSTRESS L2 HDF5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python ECOSTRESS_L2_LSTE_30192_017_20231102T165047_0601_01.h5.py

The HDF5 files must be in your current working directory.

Tested under: Python 3.9.3 :: Miniconda
Last updated: 2023-11-03
"""
import os

import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.basemap import Basemap

import h5py

FILE_NAME = "ECOSTRESS_L2_LSTE_30192_017_20231102T165047_0601_01.h5"
FILE_NAME_GEO = "ECOSTRESS_L1B_GEO_30192_017_20231102T165047_0601_01.h5"

with h5py.File(FILE_NAME, mode="r") as f, h5py.File(
    FILE_NAME_GEO, mode="r"
) as g:
    name = "/SDS/LST"
    data = f[name][:].astype(np.float64)

    # Read attributes.
    scale = f[name].attrs["scale_factor"]
    offset = f[name].attrs["add_offset"]
    units = f[name].attrs["units"].decode()
    fill_value = f[name].attrs["_FillValue"]
    long_name = f[name].attrs["long_name"].decode()

    lon = g["/Geolocation/longitude"][:].astype(np.float64)
    lat = g["/Geolocation/latitude"][:].astype(np.float64)

    # Apply fill value and scale factor.
    data[data == fill_value] = np.nan
    data = scale * data + offset
    data = np.ma.masked_array(data, np.isnan(data))
    lat = np.ma.masked_array(lat, np.isnan(data))
    lon = np.ma.masked_array(lon, np.isnan(data))

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
        lon, lat, c=data, s=1, cmap=plt.cm.jet, edgecolors=None, linewidth=0
    )
    cb = m.colorbar()
    cb.set_label(units)

    basename = os.path.basename(FILE_NAME)
    plt.title("{0}\n{1}".format(basename, long_name))
    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)