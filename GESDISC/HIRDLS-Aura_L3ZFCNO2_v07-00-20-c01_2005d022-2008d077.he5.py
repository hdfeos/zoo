"""

This example code illustrates how to access and visualize a GESDISC HIRDLS
Zonal Average HDF-EOS5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python HIRDLS-Aura_L3ZFCNO2_v07-00-20-c01_2005d022-2008d077.he5.py

The HDF-EOS5 file must be in your current working directory.

Tested under: Python 3.7.3 :: Anaconda 
Last updated: 2019-11-04
"""

import datetime
import os

import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

import h5py
from matplotlib.ticker import FormatStrFormatter

FILE_NAME = 'HIRDLS-Aura_L3ZFCNO2_v07-00-20-c01_2005d022-2008d077.he5'

with h5py.File(FILE_NAME, mode='r') as f:
    dset_var = f['/HDFEOS/ZAS/HIRDLS/Data Fields/NO2Ascending']
    dset_lat = f['/HDFEOS/ZAS/HIRDLS/Data Fields/Latitude']
    dset_lev = f['/HDFEOS/ZAS/HIRDLS/Data Fields/Pressure']
    dset_date = f['/HDFEOS/ZAS/HIRDLS/Data Fields/Time']
    dset_nco = f['HDFEOS/ZAS/HIRDLS/nCoeffs']
    
    # Read the data.
    data = dset_var[0,:,:,0]
    lat = dset_lat[:]
    lev = dset_lev[:]
    time = dset_date[0]
    nco = dset_nco[0]

    # Read the needed attributes.
    # String attributes actually come in as the bytes type and should
    # be decoded to UTF-8 (python3).
    data_units = dset_var.attrs['Units'].decode()
    lat_units = dset_lat.attrs['Units'].decode()
    lev_units = dset_lev.attrs['Units'].decode()

    data_title = dset_var.attrs['Title'].decode()
    lat_title = dset_lat.attrs['Title'].decode()
    lev_title = dset_lev.attrs['Title'].decode()

    # H5PY doesn't automatically turn the data into a masked array.
    fillvalue = dset_var.attrs['_FillValue']
    data[data == fillvalue] = np.nan
    data = np.ma.masked_array(data, np.isnan(data))

    # The date is stored as a six-digit number, YYYYMM.  Convert it into
    # a string.
    datestr = datetime.datetime(1993,1,1) + datetime.timedelta(seconds=time)

    plt.contourf(lat, lev, data)
    cb = plt.colorbar()
    cb.set_label(data_units)
    
    plt.xlabel('{0} ({1})'.format(lat_title, lat_units))
    plt.ylabel('{0} ({1})'.format(lev_title, lev_units))

    basename = os.path.basename(FILE_NAME)
    dstr = datestr.strftime('%Y-%m-%d %H:%M:%S')
    plt.title('{0}\n{1}\n at {2} and nCoeffs={3}'.format(basename, data_title,
                                                         dstr, nco))
    
    # This is useful for putting high pressure at the bottom.
    plt.gca().invert_yaxis()
    
    # Apply log scale along the y-axis to get a better image.    
    plt.gca().set_yscale('log')

    # Remove scientific notation (e.g., 1x10^0).
    plt.gca().yaxis.set_major_formatter(FormatStrFormatter('%.1f'))
    
    fig = plt.gcf()


    pngfile = "{0}.py.png".format(basename)    
    fig.savefig(pngfile)

