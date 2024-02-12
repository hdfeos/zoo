"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize a MOPITT ASDC MOP03T 
version 9 HDF-EOS5 Grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage: save this script and run

    $python MOP03T-20131129-L3V5.9.1.he5.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.1::Miniconda
Last updated: 2021-11-11

"""

import os
import re
import h5py

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from mpl_toolkits.basemap import Basemap

FILE_NAME = 'MOP03T-20131129-L3V5.9.1.he5'

with h5py.File(FILE_NAME, mode='r') as f:
    group = f['/HDFEOS/GRIDS/MOP03/Data Fields']
    dsname = 'RetrievedSurfaceTemperatureDay'
    data = group[dsname][:].T
    longname = group[dsname].attrs['long_name'].decode()
    units = group[dsname].attrs['units'].decode()
    fillvalue = group[dsname].attrs['_FillValue']

    data[data == fillvalue] = np.nan
    data = np.ma.masked_array(data, np.isnan(data))

    # We could query the string dataset
    # '/HDFEOS INFORMATION/StructMetadata.0' for the geolocation
    # information, but in this case we also have lat and lon datasets.
    y = f['/HDFEOS/GRIDS/MOP03/Data Fields/Latitude'][:]
    x = f['/HDFEOS/GRIDS/MOP03/Data Fields/Longitude'][:]
    longitude, latitude = np.meshgrid(x, y)

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
    plt.title('{0}\n{1}'.format(basename,  longname))
    fig = plt.gcf()
    # plt.show()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)

