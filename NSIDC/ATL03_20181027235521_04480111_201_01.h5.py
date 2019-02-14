"""
Copyright (C) 2018 The HDF Group

This example code illustrates how to access and visualize an NSIDC 
ICESat-2 ATL03 L2 HDF5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

   $python ATL03_20181027235521_04480111_201_01.h5.py

The HDF5 file must in your current working directory.

Tested under: Python 2.7.15 :: Anaconda custom (64-bit)
Last updated: 2018-11-19
"""

import os
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

import h5py

FILE_NAME = 'ATL03_20181027235521_04480111_201_01.h5'    
with h5py.File(FILE_NAME, mode='r') as f:

    # Ground Track L1
    latvar = f['/gt1l/geolocation/reference_photon_lat']
    latitude = latvar[:]
    lat_vr = [latvar.attrs['valid_min'], latvar.attrs['valid_max']]
    
    lonvar = f['/gt1l/geolocation/reference_photon_lon']
    longitude = lonvar[:]
    lon_vr = [lonvar.attrs['valid_min'], lonvar.attrs['valid_max']]

    # If you want to plot surface type, use the following dataset.
    # tempvar = f['/gt1l/geolocation/surf_type']

    # The above dataset has the shape of 121,757 x 5.
    # land = 0, ocean=1, sea ice=2, land ice=3, inland water=4
    
    # For land, use 0.
    # temp = tempvar[:,0]
    # temp_vr = [tempvar.attrs['valid_min'], tempvar.attrs['valid_max']]
    
    # We'll plot pulse energy.
    tempvar = f['/gt1l/geolocation/tx_pulse_energy']
    temp = tempvar[:]
    units = tempvar.attrs['units']
    long_name = tempvar.attrs['long_name']
    

    # Draw an equidistant cylindrical projection using the low resolution
    # coastline database.
    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat = 90,
                llcrnrlon=-180, urcrnrlon = 180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90., 120., 30.))
    m.drawmeridians(np.arange(-180, 180., 45.))
    m.scatter(longitude, latitude, c=temp, s=1, cmap=plt.cm.jet,
              edgecolors=None, linewidth=0)
    cb = m.colorbar(format='%.2e')
    # With scientific notation, set_label will not display units properly.
    # cb.set_label(units)
    #
    # Use set_title instead.
    cb.ax.set_title(units)    
    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, long_name))
    
    fig = plt.gcf()    
    # plt.show()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
