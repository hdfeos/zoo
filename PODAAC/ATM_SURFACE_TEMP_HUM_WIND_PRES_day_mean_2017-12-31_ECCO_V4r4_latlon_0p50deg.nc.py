"""

This example code illustrates how to access and visualize a PO.DACC
ECCO L4 netCDF-4/HDF5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

   $python ATM_SURFACE_TEMP_HUM_WIND_PRES_day_mean_2017-12-31_ECCO_V4r4_latlon_0p50deg.nc.py

The netCDF-4/HDF5 file must in your current working directory.

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2022-08-05
"""

import os
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

import h5py

FILE_NAME = 'ATM_SURFACE_TEMP_HUM_WIND_PRES_day_mean_2017-12-31_ECCO_V4r4_latlon_0p50deg.nc'
with h5py.File(FILE_NAME, mode='r') as f:

    latvar = f['/latitude']
    latitude = latvar[:]
    
    lonvar = f['/longitude']
    longitude = lonvar[:]

    
    dset_name = '/EXFatemp'
    datavar = f[dset_name]
    data = datavar[0][:][:]
    units = datavar.attrs['units']
    long_name = datavar.attrs['long_name']
    _FillValue = datavar.attrs['_FillValue']

    # Handle FillValue
    data[data == _FillValue] = np.nan
    data = np.ma.masked_where(np.isnan(data), data)    

    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon=180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90, 91, 45))
    m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
    m.pcolormesh(longitude, latitude, data, latlon=True, shading='auto')
    cb = m.colorbar()
    units = units.decode('ascii', 'replace')
    cb.set_label(units)
    long_name = long_name.decode('ascii', 'replace')
    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, long_name), fontsize=8)
    pngfile = "{0}.py.png".format(basename)
    fig = plt.gcf()
    fig.savefig(pngfile)

