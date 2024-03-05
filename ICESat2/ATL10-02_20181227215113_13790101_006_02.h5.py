"""

This example code illustrates how to access and visualize an
NSIDC ICESat-2 ATL10 L3A version 6 HDF5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

   $python ATL10-02_20181227215113_13790101_006_02.h5.py

The HDF5 file must in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2024-03-05
"""

import datetime
import os

import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.basemap import Basemap

import h5py

FILE_NAME = "ATL10-02_20181227215113_13790101_006_02.h5"
with h5py.File(FILE_NAME, mode="r") as f:

    # Ground Track L1
    latvar = f["/gt1r/freeboard_segment/geophysical/latitude"]
    latitude = latvar[:]

    lonvar = f["/gt1r/freeboard_segment/geophysical/longitude"]
    longitude = lonvar[:]

    dset_name = "/gt1r/freeboard_segment/beam_fb_height"
    datavar = f[dset_name]
    data = datavar[:]
    units = datavar.attrs["units"]
    long_name = datavar.attrs["long_name"]
    long_name = long_name.decode('ascii', 'replace')
    _FillValue = datavar.attrs["_FillValue"]

    # Handle FillValue
    data[data == _FillValue] = np.nan
    data = np.ma.masked_where(np.isnan(data), data)

    timevar = f["/gt1r/freeboard_segment/geophysical/delta_time"]
    time = timevar[:]

    # Make a split window plot.  First plot is time vs. height.
    fig = plt.figure(figsize=(10, 10))
    ax1 = plt.subplot(2, 1, 1)
    elapsed_time = time - time[0]
    timebase = datetime.datetime(2018, 1, 1, 0, 0, 0) + datetime.timedelta(
        seconds=time[0]
    )
    timedatum = timebase.strftime("%Y-%m-%dT%H:%M:%SZ")
    tunits = "Seconds from " + timedatum

    ax1.plot(elapsed_time, data, "bo")
    ax1.set_xlabel(tunits)
    ax1.set_ylabel(str(units))

    basename = os.path.basename(FILE_NAME)

    ax1.set_title("{0}\n{1}\n{2}".format(basename, dset_name, long_name))

    # The 2nd plot is the trajectory.
    ax3 = plt.subplot(2, 1, 2)
    m = Basemap(
        projection="ortho",
        resolution="l",
        lat_0=latitude[0],
        lon_0=longitude[0],
    )
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-80.0, -0.0, 20.0))
    m.drawmeridians(np.arange(-180.0, 181.0, 20.0))
    x, y = m(longitude, latitude)
    m.plot(x, y)

    # Annotate the starting point.  Offset the annotation text by 200 km.
    m.plot(x[0], y[0], marker="o", color="red")
    plt.annotate(
        "START", xy=(x[0] + 200000, y[0]), xycoords="data", color="red"
    )
    plt.title("Trajectory of Flight Path")

    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
