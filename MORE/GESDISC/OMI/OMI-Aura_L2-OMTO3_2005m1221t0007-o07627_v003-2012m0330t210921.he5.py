"""
This example code illustrates how to access and visualize
a GES DISC OMI L2 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage: save this script and run

 $python OMI-Aura_L2-OMTO3_2005m1221t0007-o07627_v003-2012m0330t210921.he5.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2024-07-24
"""

import os

import cartopy.crs as ccrs
import matplotlib.pyplot as plt
import numpy as np

import h5py

FILE_NAME = "OMI-Aura_L2-OMTO3_2005m1221t0007-o07627_v003-2012m0330t210921.he5"
path = "/HDFEOS/SWATHS/OMI Column Amount O3/Data Fields/"
DATAFIELD_NAME = path + "ColumnAmountO3"
with h5py.File(FILE_NAME, mode="r") as f:
    dset = f[DATAFIELD_NAME]
    data = dset[:].astype(np.float64)

    # Retrieve any attributes that may be needed later.
    # String attributes actually come in as the bytes type and should
    # be decoded to UTF-8 (python3).
    scale = f[DATAFIELD_NAME].attrs["ScaleFactor"]
    offset = f[DATAFIELD_NAME].attrs["Offset"]
    missing_value = f[DATAFIELD_NAME].attrs["MissingValue"]
    fill_value = f[DATAFIELD_NAME].attrs["_FillValue"]
    title = f[DATAFIELD_NAME].attrs["Title"].decode()
    units = f[DATAFIELD_NAME].attrs["Units"].decode()

    # Retrieve the geolocation data.
    path = "/HDFEOS/SWATHS/OMI Column Amount O3/Geolocation Fields/"
    latitude = f[path + "Latitude"][:]
    longitude = f[path + "Longitude"][:]

    data[data == missing_value] = np.nan
    data[data == fill_value] = np.nan
    data = scale * (data - offset)
    datam = np.ma.masked_where(np.isnan(data), data)

    # Find middle location for center of map.
    # lat_m = np.nanmean(latitude)
    # lon_m = np.nanmean(longitude)

    # Or use South Pole.
    lat_m = -90
    lon_m = 0

    # Use ortho projection.
    orth = ccrs.Orthographic(
        central_longitude=lon_m, central_latitude=lat_m, globe=None
    )
    ax = plt.axes(projection=orth)
    # Remove the following to see zoom-in view.
    ax.set_global()
    p = plt.pcolormesh(
        longitude, latitude, datam, shading="auto", transform=ccrs.PlateCarree()
    )

    # Gridline with draw_labels=True doesn't work on ortho.
    # ax.gridlines(draw_labels=True)
    ax.gridlines()
    ax.coastlines()
    cb = plt.colorbar(p)
    cb.set_label(units)

    basename = os.path.basename(FILE_NAME)
    plt.title("{0}\n{1}".format(basename, title), fontsize=8)
    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
