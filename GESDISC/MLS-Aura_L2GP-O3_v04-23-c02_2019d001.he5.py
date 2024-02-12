"""

This example code illustrates how to access and visualize a GES DISC MLS
O3 HDF-EOS5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MLS-Aura_L2GP-O3_v04-23-c02_2019d001.he5.py

The HDF-EOS5 file must be in your current working directory.

Tested under: Python Python 3.7.3 :: Anaconda custom (64-bit)
Last updated: 2020-11-10
"""

import os
import h5py
import datetime

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
from matplotlib.ticker import FormatStrFormatter


FILE_NAME = "MLS-Aura_L2GP-O3_v04-23-c02_2019d001.he5"
with h5py.File(FILE_NAME, mode='r') as f:
    dset_var = f['HDFEOS/SWATHS/O3/Data Fields/L2gpValue']
    dset_lat = f['HDFEOS/SWATHS/O3/Geolocation Fields/Latitude']
    dset_lev = f['HDFEOS/SWATHS/O3/Geolocation Fields/Pressure']
    time = f['HDFEOS/SWATHS/O3/Geolocation Fields/Time']
   
    # Read the data.
    # The latitude is not monotonic. Subset points that are monotonic.
    data = dset_var[:70,:]
    lat = dset_lat[:70]
    lev = dset_lev[:70]

    # Read the needed attributes.
    # String attributes actually come in as the bytes type and should
    # be decoded to UTF-8 (python3).
    data_units = dset_var.attrs['Units'].decode()
    lat_units = dset_lat.attrs['Units'].decode()
    lev_units = dset_lev.attrs['Units'].decode()

    data_title = dset_var.attrs['Title'].decode()
    lat_title = dset_lat.attrs['Title'].decode()
    lev_title = dset_lev.attrs['Title'].decode()

    # Handle fill value.
    fillvalue = dset_var.attrs['_FillValue']
    data[data == fillvalue] = np.nan
    data = np.ma.masked_array(data, np.isnan(data))
    
    # The date is stored as a six-digit number, YYYYMM.
    # Convert it into a string.
    datestr = datetime.datetime(1993,1,1) + datetime.timedelta(seconds=time[0])
    datestr2 = datetime.datetime(1993,1,1) + datetime.timedelta(seconds=time[70])
    
    # Apply log scale along the y-axis to get a better image.
    x, y = np.meshgrid(lat, lev)

    # contourf() will not work well for this dataset.
    # plt.contourf(lat, lev, data.T)
    plt.pcolormesh(lat, lev, data.T)
    cb = plt.colorbar()
    cb.set_label(data_units)
   
    plt.xlabel('{0} ({1})'.format(lat_title, lat_units))
    plt.ylabel('{0} ({1})'.format(lev_title, lev_units))

    basename = os.path.basename(FILE_NAME)
    dstr = datestr.strftime('%Y-%m-%d %H:%M:%S')
    dstr2 = datestr2.strftime('%Y-%m-%d %H:%M:%S')
    
    plt.title('{0}\n{1}\n from {2} to {3}'.format(basename, data_title,
                                                  dstr, dstr2))
    # This is useful for putting high pressure at the bottom.
    plt.gca().invert_yaxis()
    plt.gca().set_yscale('log')
    plt.gca().yaxis.set_major_formatter(FormatStrFormatter('%.1f'))

    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)    
    fig.savefig(pngfile)
