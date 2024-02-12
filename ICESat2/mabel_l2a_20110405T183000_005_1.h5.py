"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize a ICESat-2 mabel
swath file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python mabel_l2a_20110405T183000_005_1.h5.py

The HDF5 file must either be in your current working directory or in a directory
specified by the environment variable HDFEOS_ZOO_DIR.

Last Update: 2015/09/01
"""
import os
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np
import h5py

def run(FILE_NAME):
    with h5py.File(FILE_NAME, mode='r') as f:
    
        latvar = f['/photon/channel001/latitude']
        latitude = latvar[:]
        
        lonvar = f['/photon/channel001/longitude']
        longitude = lonvar[:]
    
        elevvar = f['/photon/channel001/elev']
        elev = elevvar[:]
        units = elevvar.attrs['units']
    
        timevar = f['/photon/channel001/delta_time']
        time = timevar[:]
            
    # Just use a small subset.
    n = time.size
    step = np.ceil(n / 100)
    idx = slice(0, n, step+1)

    # Make a split window plot.  First plot is time vs. elevation
    fig = plt.figure(figsize = (10, 15))
    ax1 = plt.subplot(3, 1, 1)
    elapsed_time = (time - time[0])
    ax1.plot(elapsed_time[idx], elev[idx], 'b-*')
    ax1.set_xlabel('Elapsed Time (seconds)')
    ax1.set_ylabel(units)

    basename = os.path.basename(FILE_NAME)
    longname = '100 sample points of channel001'
    
    ax1.set_title('{0}\n{1}'.format(basename, longname))

    # The 2nd plot is starting location on world map.
    ax2 = plt.subplot(3, 1, 2)
    plt.title('Starting Location of Flight Path')
    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat = 90,
                llcrnrlon=-180, urcrnrlon = 180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90, 91, 45))
    m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
    m.plot(longitude[0], latitude[0], linestyle='None', marker='+',
           color='red', latlon=True, markersize=24)
    
    # The 3rd plot is the trajectory.
    ax3 = plt.subplot(3, 1, 3)
    latmin = np.min(latitude)
    latmax = np.max(latitude)
    lonmin = np.min(longitude)
    lonmax = np.max(longitude)
    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=latmin, urcrnrlat = latmax,
                llcrnrlon=lonmin, urcrnrlon = lonmax)                
    m.drawparallels(np.arange(latmin, latmax, (latmax-latmin)/3),
                    labels=[True,False,False,True])
    m.drawmeridians(np.arange(lonmin, lonmax, (lonmax-lonmin)/3),
                    labels=[True,False,False,True])    
    m.plot(longitude[idx], latitude[idx], linestyle='None', marker='.',
            color='blue', latlon=True)
    plt.text(longitude[0], latitude[0], '+', color='red')
    plt.title('Trajectory of Flight Path')

    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)

if __name__ == "__main__":

    # If a certain environment variable is set, look there for the input
    # file, otherwise look in the current directory.
    hdffile = 'mabel_l2a_20110405T183000_005_1.h5'

    try:
        hdffile = os.path.join(os.environ['HDFEOS_ZOO_DIR'], hdffile)
    except KeyError:
        pass

    run(hdffile)

