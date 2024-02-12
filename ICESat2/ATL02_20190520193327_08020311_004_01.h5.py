"""

This example code illustrates how to access and visualize a ICESat-2 ATL02
file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage: save this script and run

    $python ATL02_20190520193327_08020311_004_01.h5.py

The HDF5 file must be in your current working directory.

Tested under: Python 3.6.7 :: Anaconda custom (64-bit)
Last Update: 2021/05/05
"""
import os
import h5py
import datetime
import numpy as np
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER

FILE_NAME = 'ATL02_20190520193327_08020311_004_01.h5'
with h5py.File(FILE_NAME, mode='r') as f:
    
    latvar = f['/gpsr/navigation/latitude']
    latitude = latvar[:]
    
    lonvar = f['/gpsr/navigation/longitude']
    longitude = lonvar[:]

    dsetname = '/atlas/pce1/background/bg_cnt_50shot_s'
    elevvar = f[dsetname]
    elev = elevvar[:]
    units = elevvar.attrs['units']
    units = units.decode('ascii', 'replace')
    longname = elevvar.attrs['long_name']
    longname = longname.decode('ascii', 'replace')
    
    timevar = f['/atlas/pce1/background/delta_time']
    time = timevar[:]

    # Make a split window plot.  First plot is time vs. counts.
    fig = plt.figure(figsize = (10, 10))
    ax1 = plt.subplot(2, 1, 1)
    elapsed_time = (time - time[0])
    timebase = datetime.datetime(2018, 1, 1, 0, 0, 0) + \
               datetime.timedelta(seconds=time[0])
    timedatum = timebase.strftime('%Y-%m-%dT%H:%M:%SZ')
    tunits = 'Seconds from '+timedatum

    ax1.plot(elapsed_time, elev, 'bo')
    ax1.set_xlabel(tunits)
    ax1.set_ylabel(str(units))

    basename = os.path.basename(FILE_NAME)
    
    ax1.set_title('{0}\n{1}\n{2}'.format(basename, dsetname, longname))
    # Find the middle location.
    lat_m = latitude[int(latitude.shape[0]/2)]
    lon_m = longitude[int(longitude.shape[0]/2)]
    orth = ccrs.Orthographic(central_longitude=lon_m,
                             central_latitude=lat_m,
                             globe=None)
    
    # The 2nd plot is the trajectory.
    ax3 = plt.subplot(2, 1, 2, projection=orth)
    
    # Put grids.
    gl = ax3.gridlines(draw_labels=True, dms=True)

    ax3.set_global()
    # Put coast lines.
    ax3.coastlines()
    ax3.plot(longitude, latitude, color='blue', linewidth='2',
             transform=ccrs.Geodetic())

    # Annotate the starting point.  Offset the annotation text by 200 km.
    ax3.plot(longitude[0], latitude[0], marker='o', color='red',
             transform=ccrs.Geodetic())
    ax3.text(longitude[0] + 1.0, latitude[0], 'START', color='red',
             transform=ccrs.Geodetic())
    ax3.set_title('Trajectory of Flight Path')

    # Add spacing between subplots.
    fig.tight_layout(pad=3.0)
    
    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)


