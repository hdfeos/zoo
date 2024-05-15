"""

This example code illustrates how to access and visualize an PO.DAAC
SWOT L2 netCDF-4/HDF5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

   $python SWOT_GPR_2PfP009_584_20240124_232805_20240125_001932.nc.py

The HDF5 file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2024-05-15
"""

import os

import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.basemap import Basemap

import h5py

FILE_NAME = "SWOT_GPR_2PfP009_584_20240124_232805_20240125_001932.nc"
with h5py.File(FILE_NAME, mode="r") as f:

    latvar = f["/data_01/latitude"]
    lat_sf = latvar.attrs["scale_factor"]
    latitude = latvar[:] * lat_sf
    lonvar = f["/data_01/longitude"]
    lon_sf = lonvar.attrs["scale_factor"]
    longitude = lonvar[:] * lon_sf
    longitude[longitude > 180] -= 360

    dset_name = "/data_01/mean_dynamic_topography"
    datavar = f[dset_name]
    units = datavar.attrs["units"]
    long_name = datavar.attrs["long_name"]
    scale_factor = datavar.attrs["scale_factor"]
    _FillValue = datavar.attrs["_FillValue"]
    data = datavar[:]
    dataf = data * scale_factor

    # Handle FillValue
    dataf[data == _FillValue] = np.nan
    dataf = np.ma.masked_where(np.isnan(dataf), dataf)

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
        c=dataf,
        s=1,
        cmap=plt.cm.jet,
        edgecolors=None,
        linewidth=0,
    )
    cb = m.colorbar(location="bottom")
    units = units.decode("ascii", "replace")
    cb.set_label(units)
    basename = os.path.basename(FILE_NAME)
    long_name = long_name.decode("ascii", "replace")
    plt.title("{0}\n{1}".format(basename, long_name))

    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
