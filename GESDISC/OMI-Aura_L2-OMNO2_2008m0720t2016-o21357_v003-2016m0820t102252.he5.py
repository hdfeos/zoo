"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize a GES DISC OMI L2 file
in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python OMI-Aura_L2-OMNO2_2008m0720t2016-o21357_v003-2016m0820t102252.he5.py

The HDF file must be in your current working directory.

Tested under: Python 2.7.13 :: Anaconda 4.3.22 
Last updated: 2018-1-18
"""

import os

import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np
import h5py

FILE_NAME = 'OMI-Aura_L2-OMNO2_2008m0720t2016-o21357_v003-2016m0820t102252.he5'
path = '/HDFEOS/SWATHS/ColumnAmountNO2/Data Fields/'
DATAFIELD_NAME = path + 'CloudFraction'
with h5py.File(FILE_NAME, mode='r') as f:
    dset = f[DATAFIELD_NAME]
    data =dset[:].astype(np.float64)

    # Retrieve any attributes that may be needed later.
    # String attributes actually come in as the bytes type and should
    # be decoded to UTF-8 (python3).
    scale = f[DATAFIELD_NAME].attrs['ScaleFactor']
    offset = f[DATAFIELD_NAME].attrs['Offset']
    missing_value = f[DATAFIELD_NAME].attrs['MissingValue']
    fill_value = f[DATAFIELD_NAME].attrs['_FillValue']
    title = f[DATAFIELD_NAME].attrs['Title'].decode()
    units = f[DATAFIELD_NAME].attrs['Units'].decode()

    # Retrieve the geolocation data.
    path = '/HDFEOS/SWATHS/ColumnAmountNO2/Geolocation Fields/'
    latitude = f[path + 'Latitude'][:]
    longitude = f[path + 'Longitude'][:]

    data[data == missing_value] = np.nan
    data[data == fill_value] = np.nan
    data = scale * (data - offset)
    datam = np.ma.masked_where(np.isnan(data), data)

    # Draw an equidistant cylindrical projection using the low resolution
    # coastline database.
    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat = 90,
                llcrnrlon=-180, urcrnrlon = 180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90., 120., 30.), labels=[1, 0, 0, 0])
    m.drawmeridians(np.arange(-180, 180., 45.), labels=[0, 0, 0, 1])
    m.scatter(longitude, latitude, c=datam, s=1, cmap=plt.cm.jet,
             edgecolors=None, linewidth=0)    
    cb = m.colorbar()
    cb.set_label(units)


    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, title), fontsize=8)
    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
