"""

This example code illustrates how to access and visualize an NSIDC 
ICESat-2 ATL19 L3B version 1 HDF5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

   $python ATL19_20181001010615_00370101_001_01.h5.py

The HDF5 file must in your current working directory.

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2022-01-10
"""

import os
import h5py

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from mpl_toolkits.basemap import Basemap

FILE_NAME = 'ATL19_20181001010615_00370101_001_01.h5'
with h5py.File(FILE_NAME, mode='r') as f:

    latvar = f['/mid_latitude/latitude']
    latitude = latvar[:]
    
    lonvar = f['/mid_latitude/longitude']
    longitude = lonvar[:]
    
    dset_name = '/mid_latitude/beam_1/dot_avg'
    datavar = f[dset_name]
    data = datavar[:]
    units = datavar.attrs['units']
    long_name = datavar.attrs['long_name']
    _FillValue = datavar.attrs['_FillValue']

    # Handle FillValue
    data[data == _FillValue] = np.nan
    data = np.ma.masked_where(np.isnan(data), data)    

    # Draw an equidistant cylindrical projection using the low resolution
    # coastline database.
    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat = 90,
                llcrnrlon=-180, urcrnrlon = 180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90., 120., 30.))
    m.drawmeridians(np.arange(-180, 180., 45.))
    m.pcolormesh(longitude, latitude, data, latlon=True)
    cb = m.colorbar(location='bottom')
    units = units.decode('ascii', 'replace')        
    cb.set_label(units)
    basename = os.path.basename(FILE_NAME)

    long_name = long_name.decode('ascii', 'replace')
    plt.title('{0}\n{1}'.format(basename, long_name))
    
    fig = plt.gcf()    
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
