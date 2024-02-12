"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize a GES DISC MEaSUREs
Ozone Zonal Average HDF5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python BUV-Nimbus04_L3zm_v01-02-2013m0422t101810.h5.py

The HDF file must be in your current working directory.

Tested under: Python 3.7.3 :: Anaconda
Last updated: 2019-11-04
"""

import datetime
import os

import h5py
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
from matplotlib.ticker import FormatStrFormatter

FILE_NAME = 'BUV-Nimbus04_L3zm_v01-02-2013m0422t101810.h5'

with h5py.File(FILE_NAME, mode='r') as f:

    dset_var = f['/Data_Fields/ProfileOzone']
    dset_lat = f['/Data_Fields/Latitude']
    dset_lev = f['/Data_Fields/ProfilePressureLevels']
    dset_date = f['/Data_Fields/Date']

    # Read the data.
    data = dset_var[0,:,:]
    lat = dset_lat[:]
    lev = dset_lev[:]
    date = dset_date[0]

    # Read the needed attributes.
    # String attributes actually come in as the bytes type and should
    # be decoded to UTF-8 (python3).
    data_units = dset_var.attrs['units'].decode()
    lat_units = dset_lat.attrs['units'].decode()
    lev_units = dset_lev.attrs['units'].decode()
    data_longname = dset_var.attrs['long_name'].decode()
    lat_longname = dset_lat.attrs['long_name'].decode()
    lev_longname = dset_lev.attrs['long_name'].decode()

    # H5PY doesn't automatically turn the data into a masked array.
    fillvalue = dset_var.attrs['_FillValue']
    data[data == fillvalue] = np.nan
    data = np.ma.masked_array(data, np.isnan(data))

    # The date is stored as a six-digit number, YYYYMM.  Convert it into
    # a string.
    datestr = datetime.date(int(str(date)[0:4]), int(str(date)[4:6]), 1)

    # Apply log scale along the y-axis to get a better image.
    plt.contourf(lat, lev, data.T)
    cb = plt.colorbar()
    cb.set_label('Unit:'+data_units)
    plt.xlabel('{0} ({1})'.format(lat_longname, lat_units))
    plt.ylabel('{0} ({1})'.format(lev_longname, lev_units))
    basename = os.path.basename(FILE_NAME)         
    plt.title('{0}\n{1}'.format(basename,data_longname))
    # Text position (80.0, -1.2) is relative to axes values.
    plt.text(85.0, -1.2, 'Date:{0}'.format(datestr.strftime('%Y-%m')), 
             fontsize=8)

    # This is useful for putting high pressure at the bottom.
    plt.gca().invert_yaxis()
    
    # Apply log scale along the y-axis to get a better image.    
    plt.gca().set_yscale('log')

    # Remove scientific notation (e.g., 1x10^0).
    plt.gca().yaxis.set_major_formatter(FormatStrFormatter('%.1f'))
    
    fig = plt.gcf()

    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)

