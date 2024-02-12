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

   $python 20100619062008-JPL-L2P_GHRSST-SSTskin-MODIS_A-N-v02.0-fv01.0.nc.py

The netCDF-4/HDF5 file must in your current working directory.

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2022-05-26
"""

import os
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

import h5py

FILE_NAME = '20100619062008-JPL-L2P_GHRSST-SSTskin-MODIS_A-N-v02.0-fv01.0.nc'
with h5py.File(FILE_NAME, mode='r') as f:

    latvar = f['/lat']
    latitude = latvar[:]
    
    lonvar = f['/lon']
    longitude = lonvar[:]
    
    dset_name = '/sea_surface_temperature'
    datavar = f[dset_name]
    # data = datavar[0][:][:]
    data = np.float32(datavar[:])
    units = datavar.attrs['units']
    long_name = datavar.attrs['long_name']
    _FillValue = datavar.attrs['_FillValue']
    scale_factor = datavar.attrs['scale_factor']
    add_offset = datavar.attrs['add_offset']
    
    # Handle FillValue
    data[data == _FillValue] = np.nan
    data = np.ma.masked_where(np.isnan(data), data)

    # Apply scale_factor and offset.
    data = scale_factor * data + add_offset
    
    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon=180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90, 91, 45))
    m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
    m.scatter(longitude, latitude, c=data, s=1, cmap=plt.cm.jet,
              edgecolors=None, linewidth=0)
    cb = m.colorbar()
    cb.set_label(units[0])
    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, long_name[0]), fontsize=8)
    pngfile = "{0}.py.png".format(basename)
    fig = plt.gcf()
    fig.savefig(pngfile)

