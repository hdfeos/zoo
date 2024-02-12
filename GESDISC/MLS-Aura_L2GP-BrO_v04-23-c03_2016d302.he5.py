"""

This example code illustrates how to access and visualize a GES DISC MLS v4 [1]
Swath HDF-EOS5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python MLS-Aura_L2GP-BrO_v04-23-c03_2016d302.he5.py

The HDF file must either be in your current working directory or in a directory
specified by the environment variable HDFEOS_ZOO_DIR.

Tested under: Python 3.7.3 :: Anaconda custom (x86_64)
Last updated: 2019-11-04

References
[1] https://cmr.earthdata.nasa.gov/search/concepts/C1251101115-GES_DISC/3
[2] http://mls.jpl.nasa.gov/data/v4-2_data_quality_document.pdf
"""

import os

import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np
import datetime
from matplotlib.ticker import FormatStrFormatter
from matplotlib.ticker import ScalarFormatter

import h5py
        
FILE_NAME = 'MLS-Aura_L2GP-BrO_v04-23-c03_2016d302.he5'
path = '/HDFEOS/SWATHS/BrO'
with h5py.File(FILE_NAME, mode='r') as f:
    varname = path + '/Data Fields/BrO'
    dset = f[varname]
    data = dset[399, :]

    # Retrieve any attributes that may be needed later.
    # String attributes actually come in as the bytes type and should
    # be decoded to UTF-8 (python3).
    missing_value = f[varname].attrs['MissingValue']
    fill_value = f[varname].attrs['_FillValue']
    title = f[varname].attrs['Title'].decode()
    units = f[varname].attrs['Units'].decode()

    # Retrieve the geolocation data.
    varname = path + '/Geolocation Fields/Pressure'
    pressure = f[varname][:]
    pres_units = f[varname].attrs['Units'].decode()
   
    varname = path + '/Geolocation Fields/Time'
    time = f[varname][:]

    # Read MLS Data Quality Document [2] for useful range in BrO data, which is
    # 3.2hPa - 10hPa
    plt.plot(data[12:16], pressure[12:16])
    plt.ylabel('Pressure ({0})'.format(pres_units))
    plt.xlabel('{0} ({1})'.format(title, units))
    
    basename = os.path.basename(FILE_NAME)
    timebase = datetime.datetime(1993, 1, 1, 0, 0, 0) + datetime.timedelta(seconds=time[399])
    timedatum = timebase.strftime('%Y-%m-%d %H:%M:%S')

    plt.title('{0}\n{1} at Time = {2}'.format(basename, title, timedatum))
    
    # This is useful for putting high pressure at the bottom.
    plt.gca().invert_yaxis()

    # Use log scale.
    plt.gca().set_yscale('log')

    # Remove scientific notation (e.g., 3x10^0).
    plt.gca().yaxis.set_minor_formatter(ScalarFormatter())

    # %g will take a number that could be represented as %f (a simple float or
    # double) or %e (scientific notation) and return it as the shorter of the
    # two.
    plt.gca().yaxis.set_major_formatter(FormatStrFormatter('%g'))
    
    fig = plt.gcf()

    pngfile = "{0}.py.png".format(basename)

    fig.savefig(pngfile)

