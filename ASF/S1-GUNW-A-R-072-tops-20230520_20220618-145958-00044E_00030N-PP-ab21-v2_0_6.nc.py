"""
This example code illustrates how to access and visualize an ASF
S1-GUNW netCDF-4/HDF5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python S1-GUNW-A-R-072-tops-20230520_20220618-145958-00044E_00030N-PP-ab21-v2_0_6.nc.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-07-07

"""

import os
import re
import h5py
import pyproj

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np

from mpl_toolkits.basemap import Basemap
from pyproj import Transformer

FILE_NAME = 'S1-GUNW-A-R-072-tops-20230520_20220618-145958-00044E_00030N-PP-ab21-v2_0_6.nc'
DATAFIELD_NAME = '/science/grids/data/amplitude'

with h5py.File(FILE_NAME, mode='r') as f:
    
    # Read dataset.
    datavar = f[DATAFIELD_NAME]
    
    # Subset data at time = 0.
    data = datavar[:,:]
    _FillValue = datavar.attrs['_FillValue']
    units = datavar.attrs['units']
    long_name= datavar.attrs['long_name']
    
    # Handle fill value.
    data[data == _FillValue[0]] = np.nan
    data = np.ma.masked_where(np.isnan(data), data)    

    # Read lat/lon.
    latvar = f['/science/grids/data/latitude']
    lat = latvar[:]

    lonvar = f['/science/grids/data/longitude']
    lon = lonvar[:]

    # Calculate min/max lat/lon for zoomed map.
    latmin = np.min(lat)
    latmax = np.max(lat)
    lonmin = np.min(lon)
    lonmax = np.max(lon)
    
    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=latmin, urcrnrlat = latmax,
                llcrnrlon=lonmin, urcrnrlon = lonmax)                
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(int(np.floor(latmin)), int(np.ceil(latmax)), 1),
                    labels=[True,False,False,False])
    m.drawmeridians(np.arange(int(np.floor(lonmin)), int(np.ceil(lonmax)), 1),
                    labels=[False,False,True,False])
    m.pcolormesh(lon[::50], lat[::50], data[::50, ::50],
                 latlon=True)

    cb = m.colorbar(location='bottom')
    cb.set_label(units.decode('ascii', 'replace'), fontsize=8)
    
    basename = os.path.basename(FILE_NAME)
    desc = long_name.decode('ascii', 'replace')
    plt.title('{0}\n{1}'.format(basename, desc), fontsize=8)
    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
