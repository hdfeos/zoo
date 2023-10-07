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

   $python 2A.GPM.Ka.V9-20230112.20230911-S114508-E131736.054183.V07B.HDF5.v.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-10-05
"""

import os

import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.basemap import Basemap

import h5py

file_name = "2A.GPM.Ka.V9-20230112.20230911-S114508-E131736.054183.V07B.HDF5"

with h5py.File(file_name, mode="r") as f:
    name = "/FS/SLV/zFactorFinal"
    data = f[name][:]
    units = f[name].attrs["units"]
    _FillValue = f[name].attrs["_FillValue"]
    data[data == _FillValue] = np.nan
    data = np.ma.masked_where(np.isnan(data), data)

    # Get the geolocation data.
    latitude = f["/FS/Latitude"][:]
    longitude = f["/FS/Longitude"][:]
    alt_name = "/FS/PRE/height"
    altitude = f[alt_name][:]
    alt_units = f[alt_name].attrs["units"]
    
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
    datas = data[s,:]
    lons = longitude[s]
    lats = latitude[s]
    alts = altitude[s,:]

    # Find an index that has no fill value at the height index 175.
    a = np.where(~np.isnan(datas[:,175]))
    b = np.unique(a)

    # You can pick a different location. We use the first one.
    loc = b[0]

    plt.plot(datas[loc,:], alts[loc,:])
    alt_units = alt_units.decode("ascii", "replace")    
    plt.ylabel(alt_name+' ('+alt_units+')')
    basename = os.path.basename(file_name)
    units = units.decode("ascii", "replace")
    plt.xlabel('{0} ({1})'.format(name, units))
    loc_name = 'Latitude='+str(lats[loc])+' Longitude='+str(lons[loc])
    plt.title('{0}\n{1}'.format(basename, loc_name))    

    fig = plt.gcf()
    pngfile = "{0}.v.py.png".format(basename)
    fig.savefig(pngfile)

# Reference
# [1] https://gpmweb2https.pps.eosdis.nasa.gov/pub/stout/helpdesk/filespec.GPM.V7.pdf
