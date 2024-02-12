"""

This example code illustrates how to access and visualize a GES DISC MLS H2O
Swath HDF5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MLS-Aura_L2GP-H2O_v04-20-c01_2013d003.he5.py

Tested under: Python 2.7.15::Anaconda custom (64-bit)
Last updated: 2018-12-12
"""

import os
import h5py
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

FILE_NAME = 'MLS-Aura_L2GP-H2O_v04-20-c01_2013d003.he5'

with h5py.File(FILE_NAME, mode='r') as f:

    name = '/HDFEOS/SWATHS/H2O/Data Fields/L2gpValue'
    pname = '/HDFEOS/SWATHS/H2O/Geolocation Fields/Pressure'
    subset = 0
    data = f[name][:,subset]
    pres = f[pname]
    punits = f[pname].attrs['Units'].decode() 
    units = f[name].attrs['Units'].decode() 
    longname = f[name].attrs['Title'].decode()
    
    # Get the geolocation data
    latitude = f['/HDFEOS/SWATHS/H2O/Geolocation Fields/Latitude'][:]
    longitude = f['/HDFEOS/SWATHS/H2O/Geolocation Fields/Longitude'][:]
    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon=180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90, 91, 45))
    m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
    m.scatter(longitude, latitude, c=data, s=1, cmap=plt.cm.jet,
              edgecolors=None, linewidth=0)
    # cb = m.colorbar(orientation='horizontal', format='%.1e')
    cb = m.colorbar(location="bottom", format='%.1e', pad='10%')
    cb.set_label(units)

    basename = os.path.basename(FILE_NAME)
    long_name = longname + ' at pressure='+str(pres[subset])+' '+punits
    # PRINT, s_pres
    plt.title('{0}\n{1}'.format(basename, long_name))
    fig = plt.gcf()
    # plt.show()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
