"""

This example code illustrates how to access and visualize an PO.DACC
OMG AXCTD L2 netCDF-4/HDF5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

   $python OMG_Ocean_AXCTD_L2_20160913152643.nc.py

The HDF5 file must in your current working directory.

Tested under: Python 3.7.3 :: Anaconda custom (64-bit)
Last updated: 2019-09-18
"""

import os
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

import h5py

FILE_NAME = 'OMG_Ocean_AXCTD_L2_20160913152643.nc'
with h5py.File(FILE_NAME, mode='r') as f:

    latvar = f['/lat']
    latitude = latvar[:]
    
    lonvar = f['/lon']
    longitude = lonvar[:]

    depthvar = f['/depth']
    depth = depthvar[:]
    depth_units = depthvar.attrs['units']
    
    dset_name = '/temperature'
    datavar = f[dset_name]
    data = datavar[:]
    units = datavar.attrs['units']
    long_name = datavar.attrs['long_name']
    _FillValue = datavar.attrs['_FillValue']

    # Handle FillValue
    data[data == _FillValue] = np.nan
    data = np.ma.masked_where(np.isnan(data), data)    

    plt.plot(data[0], depth[0])
    plt.ylabel('Depth ({0})'.format(depth_units.decode('ascii', 'replace')))
    long_name = long_name.decode('ascii', 'replace')        
    plt.xlabel('{0} ({1})'.format(long_name, units.decode('ascii', 'replace')))
    
    basename = os.path.basename(FILE_NAME)
    title = 'Location: lat=' + str(latitude[0]) 
    title = title + ' and lon='+ str(longitude[0])
    plt.title('{0}\n{1}'.format(basename, title))

    # This is useful for plotting sea depth.
    plt.gca().invert_yaxis()
    fig = plt.gcf()    
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)

