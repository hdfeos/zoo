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

    $python ATL02_20190520193327_08020311_001_01.h5.py

The HDF5 file must be in your current working directory.

Tested under: Python 3.6.7 :: Anaconda custom (64-bit)
Last Update: 2019/06/05
"""
import os
import h5py
import datetime
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap

FILE_NAME = 'ATL02_20190520193327_08020311_001_01.h5'
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
    
    # The 2nd plot is the trajectory.
    ax3 = plt.subplot(2, 1, 2)
    m = Basemap(projection='ortho', resolution='l',
                lat_0=latitude[0],
                lon_0=longitude[0])
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-80., -0., 20.))
    m.drawmeridians(np.arange(-180., 181., 20.))
    x, y = m(longitude, latitude)
    m.plot(x, y)

    # Annotate the starting point.  Offset the annotation text by 200 km.
    m.plot(x[0], y[0], marker='o', color='red')
    plt.annotate('START',
                 xy=(x[0] + 200000, y[0]),
                 xycoords='data',
                 color='red')
    plt.title('Trajectory of Flight Path')

    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)


