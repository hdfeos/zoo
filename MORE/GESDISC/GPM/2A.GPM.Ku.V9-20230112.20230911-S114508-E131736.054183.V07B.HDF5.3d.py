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

   $python 2A.GPM.Ku.V9-20230112.20230911-S114508-E131736.054183.V07B.HDF5.3d.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-10-06
"""

import h5py
import os

import matplotlib.pyplot as plt
import numpy as np

from mpl_toolkits.mplot3d import Axes3D
from mpl_toolkits.basemap import Basemap


file_name = "2A.GPM.Ku.V9-20230112.20230911-S114508-E131736.054183.V07B.HDF5"

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
    r = datas.shape[1]
    lons = np.squeeze(np.dstack([longitude[s]] * r))
    lats = np.squeeze(np.dstack([latitude[s]] * r))
    alts = altitude[s,:]

    data = datas[~np.isnan(datas)]
    lon = lons[~np.isnan(datas)]
    lat = lats[~np.isnan(datas)]
    alt = alts[~np.isnan(datas)]
    

    fig = plt.figure()
    ax = fig.add_subplot(projection='3d')
    ax.set_aspect('auto')
    ax.set_zlim3d(np.min(alt),np.max(alt))        
    m = Basemap(llcrnrlon=lonbounds[0], llcrnrlat=latbounds[0],
                urcrnrlon=lonbounds[1], urcrnrlat=latbounds[1],
                projection='cyl', resolution='l', fix_aspect=False, ax=ax)


    ax.add_collection3d(m.drawcoastlines(linewidth=0.25))
    
    p = ax.scatter(lon, lat, alt, c=data, cmap='jet')

    lon_step = 10.0
    lat_step = 10.0
    meridians = np.arange(np.floor(lonbounds[0]), np.ceil(lonbounds[1]) + lon_step,
                          lon_step)
    parallels = np.arange(np.floor(latbounds[0]), np.ceil(latbounds[1]) + lat_step,
                          lat_step)    
    ax.set_yticks(parallels)
    ax.set_yticklabels(parallels)
    ax.set_xticks(meridians)
    ax.set_xticklabels(meridians)    
    ax.set_xlabel('Longitude')
    ax.set_ylabel('Latitude')
    
    alt_units = alt_units.decode("ascii", "replace")
    ax.set_zlabel('Altitude ('+alt_units+')')    

    basename = os.path.basename(file_name)
    units = units.decode("ascii", "replace")
    plt.title('{0}\n{1}'.format(basename, name))    

    cb = fig.colorbar(p, location="bottom", shrink=0.5)
    cb.set_label(units)

    fig = plt.gcf()
    pngfile = "{0}.3d.py.png".format(basename)
    fig.savefig(pngfile)
    
# Reference
# [1] https://gpmweb2https.pps.eosdis.nasa.gov/pub/stout/helpdesk/filespec.GPM.V7.pdf
