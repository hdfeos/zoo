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

    $python SBUV2-NOAA17_L2-SBUV2N17L2_2011m1231_v01-02-2013m0828t143157.h5.py

The HDF file must be in your current working directory.

Tested under: Python 3.7.3 :: Anaconda
Last updated: 2019-11-04
"""
import os
import h5py
import datetime
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
from matplotlib.ticker import FormatStrFormatter

FILE_NAME = 'SBUV2-NOAA17_L2-SBUV2N17L2_2011m1231_v01-02-2013m0828t143157.h5'
with h5py.File(FILE_NAME, mode='r') as f:

    dset_var = f['/SCIENCE_DATA/ProfileO3Retrieved']
    dset_lat = f['/GEOLOCATION_DATA/Latitude']
    dset_lev = f['/ANCILLARY_DATA/PressureLevels']
    dset_time = f['nTimes']

    # Read the data.
    data = dset_var[:,:]
    lat = dset_lat[:]
    lev = dset_lev[:]
    time = dset_time[:]

    # Read the needed attributes.
    # String attributes actually come in as the bytes type and should
    # be decoded to UTF-8 (python3).
    data_units = dset_var.attrs['units'].decode()
    data_vmin = dset_var.attrs['valid_min']
    data_vmax = dset_var.attrs['valid_max']
    data_fillvalue = dset_var.attrs['_FillValue']
    lat_units = dset_lat.attrs['units'].decode()
    lev_units = dset_lev.attrs['units'].decode()
    data_longname = dset_var.attrs['long_name'].decode()
    lat_longname = dset_lat.attrs['long_name'].decode()
    lev_longname = dset_lev.attrs['long_name'].decode()

    # Apply the attribute information and transform into a masked array.
    data[data < data_vmin] = np.nan
    data[data > data_vmax] = np.nan
    data[data == data_fillvalue] = np.nan
    data = np.ma.masked_array(data, np.isnan(data))

    # The latitude is not monotonic.  It must be sorted before CONTOURF can be
    # used.
    idx = np.argsort(lat)

    # The time is stored as seconds since 1993-01-01
    # a string.
    start_time = datetime.datetime(1993,1,1) + datetime.timedelta(seconds=time[0])
    end_time = datetime.datetime(1993,1,1) + datetime.timedelta(seconds=time[70])

    # Apply log scale along the y-axis to get a better image.
    plt.contourf(lat[idx], lev, data[idx,:].T, levels=np.arange(0,60,5))
    cb = plt.colorbar()
    cb.set_label('Unit:'+data_units)

    plt.xlabel('{0} ({1})'.format(lat_longname, lat_units))
    plt.ylabel('{0} ({1})'.format(lev_longname, lev_units))
    basename = os.path.basename(FILE_NAME)         
    plt.title('{0}\n{1}'.format(basename, data_longname), fontsize=10)
    plt.text(45.0, -1.4, '{0}\n{1}'.format(start_time, end_time), 
             fontsize=8, bbox=dict(facecolor='red', alpha=0.5))

    # This is useful for putting high pressure at the bottom.
    plt.gca().invert_yaxis()
    
    # Apply log scale along the y-axis to get a better image.    
    plt.gca().set_yscale('log')

    # Remove scientific notation (e.g., 1x10^0).
    plt.gca().yaxis.set_major_formatter(FormatStrFormatter('%.1f'))
    
    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)

