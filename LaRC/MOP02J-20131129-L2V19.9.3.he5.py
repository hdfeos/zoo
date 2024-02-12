"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize a MOPITT version 9
HDF-EOS5 swath file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MOP02J-20131129-L2V19.9.3.he5.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2021-11-09
"""

import os

import h5py
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np


FILE_NAME = 'MOP02J-20131129-L2V19.9.3.he5'
with h5py.File(FILE_NAME, mode='r') as f:

    name = '/HDFEOS/SWATHS/MOP02/Data Fields/RetrievedSurfaceTemperature'
    data = f[name][:, 0]
    
    units = f[name].attrs['units'].decode()
    fillvalue = f[name].attrs['_FillValue']

    data[data == fillvalue] = np.nan

    # Get the geolocation data.
    latitude = f['/HDFEOS/SWATHS/MOP02/Geolocation Fields/Latitude'][:]
    longitude = f['/HDFEOS/SWATHS/MOP02/Geolocation Fields/Longitude'][:]

    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon=180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90, 91, 45))
    m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
    sc = m.scatter(longitude, latitude, c=data, s=1, cmap=plt.cm.jet,
                   edgecolors=None, linewidth=0)
    cb = m.colorbar()
    cb.set_label(units)

    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, 'RetrievedSurfaceTemperature'))
    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)

