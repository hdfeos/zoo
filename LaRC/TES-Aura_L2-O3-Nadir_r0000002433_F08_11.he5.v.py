"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize TES HDF-EOS5 
Swath file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python TES-Aura_L2-O3-Nadir_r0000002433_F08_11.he5.v.py

The HDF file must either be in your current working directory.

Tested under: Python 3.7.3::Anaconda
Last updated: 2019-11-05
"""


import os
import h5py
import datetime

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from mpl_toolkits.basemap import Basemap
from matplotlib.ticker import FormatStrFormatter


FILE_NAME = 'TES-Aura_L2-O3-Nadir_r0000002433_F08_11.he5'    
with h5py.File(FILE_NAME, mode='r') as f:

    group = '/HDFEOS/SWATHS/O3NadirSwath/Data Fields'
    data_var = f['/'.join([group, 'O3'])]
    o3_data = data_var[:]
    o3_longname = data_var.attrs['Title'].decode()
    o3_units = data_var.attrs['Units'].decode()
    o3_fillvalue = data_var.attrs['_FillValue']
    o3_missingvalue = data_var.attrs['MissingValue']
    o3_data[o3_data == o3_fillvalue] = np.nan
    o3_data[o3_data == o3_missingvalue] = np.nan

    pressure_var = f['/'.join([group, 'Pressure'])]
    pressure_data = pressure_var[:]
    pressure_longname = pressure_var.attrs['Title'].decode()
    pressure_units = pressure_var.attrs['Units'].decode()
    pressure_fillvalue = pressure_var.attrs['_FillValue']
    pressure_missingvalue = pressure_var.attrs['MissingValue']
    pressure_data[pressure_data == pressure_fillvalue] = np.nan
    pressure_data[pressure_data == pressure_missingvalue] = np.nan

    group = '/HDFEOS/SWATHS/O3NadirSwath/Geolocation Fields'
    time_var = f['/'.join([group, 'Time'])]
    time_data = time_var[:]

    # Time is second from TAI93.
    # See 4-25 of "TES Science Data Processing Standard and Special Observation
    # Data Products Specification" [1].
    # Please note that the computed time is off by 7 seconds from the
    # values stored in "/HDFEOS/SWATHS/O3NadirSwath/Data Fields/UTCTime".
    timebase = datetime.datetime(1993, 1, 1, 0, 0, 0)

    formatter = mpl.ticker.FormatStrFormatter('%.2g')
    basename = os.path.basename(FILE_NAME)

    xlabel = "{0} ({1})".format(o3_longname, o3_units)
    ylabel = "{0} ({1})".format(pressure_longname, pressure_units)

    ax1 = plt.subplot(2, 2, 1)
    ax1.semilogy(o3_data[55,:], pressure_data[55,:])
    ax1.set_ylabel(ylabel, fontsize=6)
    # This is useful for putting high pressure at the bottom.
    ax1.invert_yaxis()
    ax1.yaxis.set_major_formatter(FormatStrFormatter('%g'))
    
    delta =  datetime.timedelta(days=time_data[55]/86400.0)
    timedatum = (timebase + delta).strftime('%d %a %Y %H:%M:%S')
    ax1.set_title("{0}\n{1} at {2}".format(basename, o3_longname, timedatum), fontsize=6)
    ax1.set_xticks(np.arange(0e-6, 9e-6, 2e-6))
    ax1.xaxis.set_major_formatter(formatter)
    plt.tick_params(axis='both', labelsize=6)

    ax2 = plt.subplot(2, 2, 3)
    ax2.semilogy(o3_data[155,:], pressure_data[155,:])
    ax2.set_xlabel(xlabel, fontsize=6)
    ax2.set_ylabel(ylabel, fontsize=6)
    ax2.invert_yaxis()
    ax2.yaxis.set_major_formatter(FormatStrFormatter('%g'))
    
    delta =  datetime.timedelta(days=time_data[155]/86400.0)
    timedatum = (timebase + delta).strftime('%d %a %Y %H:%M:%S')
    ax2.set_title("{0} at {1}".format(o3_longname, timedatum), fontsize=6)
    ax2.xaxis.set_major_formatter(formatter)
    plt.tick_params(axis='both', labelsize=6)

    ax3 = plt.subplot(2, 2, 2)
    ax3.semilogy(o3_data[955,:], pressure_data[955,:])
    ax3.invert_yaxis()
    ax3.yaxis.set_major_formatter(FormatStrFormatter('%g'))
    delta =  datetime.timedelta(days=time_data[955]/86400.0)
    timedatum = (timebase + delta).strftime('%d %a %Y %H:%M:%S')
    ax3.set_title("{0} at {1}".format(o3_longname, timedatum), fontsize=6)
    ax3.set_xticks(np.arange(0e-6, 9e-6, 2e-6))
    ax3.xaxis.set_major_formatter(formatter)
    plt.tick_params(axis='both', labelsize=6)

    ax4 = plt.subplot(2, 2, 4)
    ax4.semilogy(o3_data[1116,:], pressure_data[1116,:])
    ax4.set_xlabel(xlabel, fontsize=6)
    ax4.invert_yaxis()
    ax4.yaxis.set_major_formatter(FormatStrFormatter('%g'))    
    delta =  datetime.timedelta(days=time_data[1116]/86400.0)
    timedatum = (timebase + delta).strftime('%d %a %Y %H:%M:%S')
    ax4.set_title("{0} at {1}".format(o3_longname, timedatum), fontsize=6)
    ax4.xaxis.set_major_formatter(formatter)
    plt.tick_params(axis='both', labelsize=6)

    fig = plt.gcf()
    pngfile = "{0}.v.py.png".format(basename)
    fig.savefig(pngfile)

# References 
# [1] http://tes.jpl.nasa.gov/uploadedfiles/TES_DPS_V11.8.pdf
