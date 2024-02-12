"""
This example code illustrates how to access and visualize an NSIDC
ATL15 vesion 2 netCDF-4 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python ATL15_AA_0314_01km_002_02.nc.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-05-05

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

FILE_NAME = 'ATL15_AA_0314_01km_002_02.nc'
DATAFIELD_NAME = '/dhdt_lag1/dhdt'

with h5py.File(FILE_NAME, mode='r') as f:
    
    # Read dataset.
    datavar = f[DATAFIELD_NAME]
    
    # Subset data at time = 0.
    data = datavar[0,:,:]    
    _FillValue = datavar.attrs['_FillValue']
    units = datavar.attrs['units']
    long_name= datavar.attrs['long_name']
    
    # Handle fill value.
    data[data == _FillValue] = np.nan
    data = np.ma.masked_where(np.isnan(data), data)    

    # Read lat/lon.
    latvar = f['/dhdt_lag1/y']
    lat = latvar[:]
    
    lonvar = f['/dhdt_lag1/x']
    lon = lonvar[:]
    
    # Read time.
    timevar = f['/dhdt_lag1/time']
    time = timevar[:] 
    t_units = timevar.attrs['units']
    
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
    desc = long_name.decode('ascii', 'replace')
    at = 'on ' + str(time[0]) + ' ' + t_units.decode('ascii', 'replace')
    plt.title('{0}\n{1}\n{2}'.format(basename, desc, at))
    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
    

