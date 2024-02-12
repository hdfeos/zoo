"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize a TES L3 CH4
HDF-EOS5 Grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python TES-Aura_L3-CH4_r0000033028_C01_F01_12.he5.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.1::Miniconda
Last updated: 2021-12-01
"""

import os
import re
import h5py

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from mpl_toolkits.basemap import Basemap


FILE_NAME = 'TES-Aura_L3-CH4_r0000033028_C01_F01_12.he5'    
with h5py.File(FILE_NAME, mode='r') as f:

    # Need to retrieve the grid metadata.  The hdfeos5 library stores it
    # in a string dataset.
    METADATA_FIELD = '/HDFEOS INFORMATION/StructMetadata.0'
    gridmeta = str(f[METADATA_FIELD][...])

    DATA_FIELD = '/HDFEOS/GRIDS/NadirGrid/Data Fields/SurfacePressure'
    data = f[DATA_FIELD][...].astype(np.float64)
    fillvalue = f[DATA_FIELD].attrs['_FillValue']
    missingvalue = f[DATA_FIELD].attrs['MissingValue']
    title = f[DATA_FIELD].attrs['Title'].decode()
    units = f[DATA_FIELD].attrs['Units'].decode()

    invalid = np.logical_or(data == fillvalue[0], data == missingvalue[0])
    data[invalid] = np.nan
    data = np.ma.masked_array(data, np.isnan(data))

    lon = f['/HDFEOS/GRIDS/NadirGrid/Data Fields/Longitude'][...].astype(np.float64)
    lat = f['/HDFEOS/GRIDS/NadirGrid/Data Fields/Latitude'][...].astype(np.float64)
    
    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon=180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-45, 91, 45), labels=[1, 0, 0, 0])
    m.drawmeridians(np.arange(-180, 180, 45), labels=[0, 0, 0, 1])

    m.pcolormesh(lon, lat, data, latlon=True)
    cb = m.colorbar()
    cb.set_label(units)

    fig = plt.gcf()
    
    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, title))

    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
