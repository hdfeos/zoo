"""

This example code illustrates how to access and visualize a GES DISC OMI v3 
Swath HDF-EOS5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python OMI-Aura_L2-OMO3PR_2017m1018t0103-o70523_v003-2017m1019t111518.he5.py

The HDF file must be in your current working directory.

Tested under: Python 3.7.3 :: Anaconda custom (x86_64)
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
        
FILE_NAME = 'OMI-Aura_L2-OMO3PR_2017m1018t0103-o70523_v003-2017m1019t111518.he5'
path = '/HDFEOS/SWATHS/O3Profile'

# Time dimension is 329.
# Lat/Lon dimensions are 329x30. 
# O3 dimension is 329x30x18.
# Pressure dimension is 329x30x19.
# According to [1], 30 is a cross track.
# Pressure has dimension size of 19 because [1] says:
# "The ozone profile is given in terms of the layer-columns of
# ozone in DU for an 18-layer atmosphere. The layers are nominally
# bounded by the pressure levels: [surface pressure, 700, 500, 300,
# 200, 150, 100, 70, 50, 30, 20, 10, 7, 5, 3, 2, 1, 0.5, and 0.3
# hPa."
# Thus, 19 indicates the bounds. 

# Set subset parameters.
tdim = 26
track = 0

with h5py.File(FILE_NAME, mode='r') as f:
    varname = path + '/Data Fields/O3'
    dset = f[varname]
    data = dset[tdim, track, :]
    # Retrieve any attributes that may be needed later.
    # String attributes actually come in as the bytes type and should
    # be decoded to UTF-8 (python3).
    missing_value = f[varname].attrs['MissingValue']
    fill_value = f[varname].attrs['_FillValue']
    title = f[varname].attrs['Title'].decode()
    units = f[varname].attrs['Units'].decode()

    # Retrieve the geolocation data.
    varname = path + '/Geolocation Fields/Pressure'
    pressure1 = f[varname][:]

    # Subset 18 points from pressure data to match 18 O3 data size.
    pressure=pressure1[tdim,track,1:];
    
    pres_units = f[varname].attrs['Units'].decode()
    pres_fill_value = f[varname].attrs['_FillValue']
    
    varname = path + '/Geolocation Fields/Time'
    time = f[varname][:]

    # Handle fill value.
    data[data == missing_value] = np.nan
    data[data == fill_value] = np.nan
    datam = np.ma.masked_where(np.isnan(data), data)

    pressure[pressure == fill_value] = np.nan
    pressurem = np.ma.masked_where(np.isnan(pressure), pressure)
    
    plt.plot(datam, pressurem)
    plt.ylabel('Pressure ({0})\n'.format(pres_units))
    plt.xlabel('{0} ({1})'.format(title, units))
    
    basename = os.path.basename(FILE_NAME)
    timebase = datetime.datetime(1993, 1, 1, 0, 0, 0) + datetime.timedelta(seconds=time[tdim])
    timedatum = timebase.strftime('%Y-%m-%d %H:%M:%S')
    title = '{0}\n{1} at Time = {2} (track={3})'.format(basename, title, \
                                                        timedatum, track)
    # Title is long. Reduce font size.
    plt.title(title, fontsize=11)

    # This is useful for putting high pressure at the bottom.    
    plt.gca().invert_yaxis()
    plt.gca().set_yscale('log')
    plt.gca().yaxis.set_major_formatter(FormatStrFormatter('%d'))    
    fig = plt.gcf()

    pngfile = "{0}.py.png".format(basename)

    fig.savefig(pngfile)

# References
# [1] https://aura.gesdisc.eosdis.nasa.gov/data//Aura_OMI_Level2/OMO3PR.003/doc/README.OMO3PR.pdf

