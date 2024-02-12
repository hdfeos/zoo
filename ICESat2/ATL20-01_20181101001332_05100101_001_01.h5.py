"""

This example code illustrates how to access and visualize an NSIDC 
ICESat-2 ATL20 L3B HDF5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

   $python ATL20-01_20181101001332_05100101_001_01.h5.py

The HDF5 file must in your current working directory.

Tested under: Python 3.7.7 :: Anaconda custom (64-bit)
Last updated: 2020-11-23
"""

import os
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

import h5py

FILE_NAME = 'ATL20-01_20181101001332_05100101_001_01.h5'
with h5py.File(FILE_NAME, mode='r') as f:

    latvar = f['/grid_lat']
    latitude = latvar[:]
    
    lonvar = f['/grid_lon']
    longitude = lonvar[:]
    # print(longitude)
    dset_name = '/monthly/mean_fb'
    datavar = f[dset_name]
    data = datavar[:]
    units = datavar.attrs['units']
    long_name = datavar.attrs['long_name']
    _FillValue = datavar.attrs['_FillValue']

    # Handle FillValue
    data[data == _FillValue] = np.nan
    data = np.ma.masked_where(np.isnan(data), data)    

    # See [1] for the origin and bounding lattitue.
    m = Basemap(projection='npstere', resolution='l',
                boundinglat=60, lon_0 = -45)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90., 120., 30.))
    m.drawmeridians(np.arange(-180, 180., 45.))
    longitude = longitude - 180
    m.pcolormesh(longitude, latitude,  data, latlon=True)
    cb = m.colorbar(location='bottom')
    units = units.decode('ascii', 'replace')        
    cb.set_label(units)
    basename = os.path.basename(FILE_NAME)
    long_name = long_name.decode('ascii', 'replace')        
    plt.title('{0}\n{1}'.format(basename, long_name))
    
    fig = plt.gcf()    
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)

# Reference
# [1] https://nsidc.org/data/ATL20/versions/1
