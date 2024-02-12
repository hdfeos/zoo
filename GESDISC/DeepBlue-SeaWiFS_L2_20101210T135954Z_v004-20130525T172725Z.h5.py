"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize a GES DISC MEaSUREs
SeaWiFS L2 swath file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

$python DeepBlue-SeaWiFS_L2_20101210T135954Z_v004-20130525T172725Z.h5.py

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

FILE_NAME = 'DeepBlue-SeaWiFS_L2_20101210T135954Z_v004-20130525T172725Z.h5'
    
with h5py.File(FILE_NAME, mode='r') as f:
    DATAFIELD_NAME = 'aerosol_optical_thickness_550_ocean'
    data = f[DATAFIELD_NAME][:]
    latitude = f['latitude'][:]
    longitude = f['longitude'][:]
    
    # String attributes actually come in as the bytes type and should
    # be decoded to UTF-8 (python3).
    long_name = f[DATAFIELD_NAME].attrs['long_name'].decode()
    units = f[DATAFIELD_NAME].attrs['units'].decode()
    
    data[data == -999] = np.nan
    data = np.ma.masked_array(data, np.isnan(data))

    # Draw an orthographic projection using the low resolution
    # coastline database.
    lat_m = np.nanmean(latitude)
    lon_m = np.nanmean(longitude)    
    m = Basemap(projection='ortho', resolution='l', lat_0=lat_m, lon_0 = lon_m)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90., 120., 30.))
    m.drawmeridians(np.arange(-180, 180., 45.))
    m.pcolormesh(longitude, latitude, data, latlon=True)
    cb = m.colorbar()
    cb.set_label('units:'+units)

    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, long_name))

    # Save plot as PNG file.
    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
