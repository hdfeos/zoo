"""
This example code illustrates how to access and visualize an NSIDC
ATL14 vesion 3 netCDF-4 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python ATL14_A2_0318_100m_003_01.nc.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2024-04-02

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

FILE_NAME = 'ATL14_A2_0318_100m_003_01.nc'
DATAFIELD_NAME = 'h'

with h5py.File(FILE_NAME, mode='r') as f:
    
    # Read dataset.
    datavar = f['/h']
    
    # Subset since dataset is too large - x:54601 * y:44601.
    data = datavar[::100, ::100]    
    _FillValue = datavar.attrs['_FillValue']
    units = datavar.attrs['units']
    long_name= datavar.attrs['long_name']
    
    # Handle fill value.
    data[data == _FillValue] = np.nan
    data = np.ma.masked_where(np.isnan(data), data)    

    # Read lat/lon.
    latvar = f['/y']
    lat = latvar[:]
    lat = lat[::100]
    
    lonvar = f['/x']
    lon = lonvar[:]
    lon = lon[::100]

    # Define the source and destination projections.
    src_proj = pyproj.CRS("EPSG:3031")
    dst_proj = pyproj.CRS("EPSG:4326")
    xv, yv = np.meshgrid(lon, lat)

    # Convert the coordinates.
    t = Transformer.from_crs(src_proj, dst_proj, always_xy=True)
    x, y = t.transform(xv, yv)

    m = Basemap(projection='spstere', resolution='l', boundinglat=-45,
                lon_0 = 0)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-80, 0, 20), labels=[1, 0, 0, 0])
    m.drawmeridians(np.arange(-180, 181, 30), labels=[0, 0, 0, 1])
    m.pcolormesh(x, y, data, latlon=True)
    cb = m.colorbar()
    cb.set_label(units.decode('ascii', 'replace'))

    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, long_name.decode('ascii', 'replace')))
    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
    

