"""

This example code illustrates how to access and visualize an NSIDC
ICESat-2 ATL08 L3A version 6 HDF5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

   $python ATL08_20210114234518_03361001_006_01.h5.py

The HDF5 file must in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2024-03-04
"""

import os

import cartopy.crs as ccrs
import matplotlib.pyplot as plt
import numpy as np
from cartopy.mpl.gridliner import LATITUDE_FORMATTER, LONGITUDE_FORMATTER

import h5py

FILE_NAME = "ATL08_20210114234518_03361001_006_01.h5"
with h5py.File(FILE_NAME, mode="r") as f:

    latvar = f["/gt1l/land_segments/latitude"]
    lat = latvar[:]
    lonvar = f["/gt1l/land_segments/longitude"]
    lon = lonvar[:]
    dset_name = "/gt1l/land_segments/dem_h"
    datavar = f[dset_name]
    data = datavar[:]
    units = datavar.attrs["units"]
    long_name = datavar.attrs["long_name"]
    _FillValue = datavar.attrs["_FillValue"]

    # Handle FillValue
    data[data == _FillValue] = np.nan
    data = np.ma.masked_where(np.isnan(data), data)

    # Find the middle location.
    lat_m = lat[int(lat.shape[0] / 2)]
    lon_m = lon[int(lon.shape[0] / 2)]

    # Let's use ortho projection.
    orth = ccrs.Orthographic(
        central_longitude=lon_m, central_latitude=lat_m, globe=None
    )
    ax = plt.axes(projection=orth)

    # Remove the following line to see a zoom-in view.
    ax.set_global()

    # Plot on map.
    p = plt.scatter(
        lon, lat, c=data, s=1, cmap=plt.cm.jet, transform=ccrs.PlateCarree()
    )

    # Put grids.
    gl = ax.gridlines(draw_labels=True, dms=True)

    # Put coast lines.
    ax.coastlines()

    # Put grid labels at left and bottom only.
    gl.top_labels = False
    gl.right_labels = False

    # Put degree N/E label.
    gl.xformatter = LONGITUDE_FORMATTER
    gl.yformatter = LATITUDE_FORMATTER

    # Adjust colorbar size and location using fraction and pad.
    cb = plt.colorbar(p, fraction=0.022, pad=0.01)
    units = units.decode("ascii", "replace")
    cb.set_label(units, fontsize=8)

    basename = os.path.basename(FILE_NAME)
    long_name = long_name.decode("ascii", "replace")
    plt.title("{0}\n{1}".format(basename, long_name))

    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
