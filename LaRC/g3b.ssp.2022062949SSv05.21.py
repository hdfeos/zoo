"""
This example code illustrates how to access and visualize a LaRC ASDC g3bssp
vertical profile HDF5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python g3b.ssp.2022062949SSv05.21.py

The HDF5 file must be in your current working directory.

Tested under: Python 3.9.12 :: Miniconda
Last updated: 2022-08-25
"""

import os
import h5py

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from matplotlib.ticker import FormatStrFormatter
from matplotlib.ticker import ScalarFormatter

FILE_NAME = 'g3b.ssp.2022062949SSv05.21'

with h5py.File(FILE_NAME, mode='r') as f:

    dset_var = f['/Altitude Based Data/Aerosol Ozone Profiles/Ozone_AO3']
    dset_pres = f['/Altitude Based Data/Altitude Information/Altitude']
    dset_time = f['/Event Information/Time']
    dset_date = f['/Event Information/Date']
    dset_lat = f['/Event Information/Latitude']
    dset_lon = f['/Event Information/Longitude']

    # Read the data.
    data = dset_var[:]
    altitude = dset_pres[:]
    time = dset_time[()]
    dt = dset_date[()]
    lat = dset_lat[()]
    lon = dset_lon[()]
    
    # Read the needed attributes.
    data_units = dset_var.attrs['units']
    pres_units = dset_pres.attrs['units']
    data_title = dset_var.attrs['long_name']
    time_title = dset_time.attrs['long_name']
    pres_title = dset_pres.attrs['long_name']

    fillvalue = dset_var.attrs['_FillValue']
    data[data == fillvalue] = np.nan

    # The date is stored as a six-digit number, YYYYMM.  Convert it into
    # a string.
    dstr = str(dt)
    ymd_str = dstr[0:4] + "-" + dstr[4:6] + "-" + dstr[6:8]

    # The time is stored as a six-digit number, HHMMSS.  Convert it into
    # a string.    
    tstr = str(time).zfill(6)
    hms_str = tstr[0:2] + ":" + tstr[2:4] + ":" + tstr[4:6]
    datestr =  ymd_str + "T" + hms_str + "Z"

    # Set lat/lon string.
    locstr = "Longitude = " + str(lon) + ", Latitude = " + str(lat)
    
    plt.plot(data, altitude)

    # Save some screen space by using scientific notation for the xtick labels.
    formatter = plt.ScalarFormatter(useMathText=True)
    formatter.set_scientific(True)
    formatter.set_powerlimits((-3, 4))
    plt.gca().xaxis.set_major_formatter(formatter)

    plt.xlabel('{0} ({1})'.format(data_title, data_units))
    plt.ylabel('{0} ({1})'.format(pres_title, pres_units))

    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1} at {2}\n{3}'.format(basename, data_title, datestr, locstr))

    # This is useful for putting high pressure at the bottom.
    # plt.gca().invert_yaxis()

    # Use log scale.
    # plt.gca().set_yscale('log')

    # %g will take a number that could be represented as %f (a simple float or
    # double) or %e (scientific notation) and return it as the shorter of the
    # two.
    plt.gca().yaxis.set_major_formatter(FormatStrFormatter('%g'))
    
    fig = plt.gcf()
    
    pngfile = "{0}.py.png".format(basename)    
    fig.savefig(pngfile)



