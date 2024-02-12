"""

This example code illustrates how to access and visualize a VNP21 NRT 
netCDF-4/HDF5 Swath file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python VNP21_NRT.A2020342.0000.001.nc.py

The HDF5 file must be in your current working directory.

Tested under: Python 3.7.7 :: Anaconda custom (x86_64)
Last updated: 2021-01-05
"""

import os

import h5py
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

FILE_NAME = 'VNP21_NRT.A2020342.0000.001.nc'
    
with h5py.File(FILE_NAME, mode='r') as f:
    
    name = '/VIIRS_Swath_LSTE/Data Fields/LST'
    data = f[name][:]
    units = f[name].attrs['units']
    units = units.decode('ascii', 'replace')
    long_name = f[name].attrs['long_name']
    long_name = long_name.decode('ascii', 'replace')
    _FillValue = f[name].attrs['_FillValue']
    add_offset = f[name].attrs['add_offset']
    scale_factor = f[name].attrs['scale_factor']
    valid_range = f[name].attrs['valid_range']
    valid_min = valid_range[0]
    valid_max = valid_range[1]
    invalid = np.logical_or(data > valid_max,
                            data < valid_min)
    invalid = np.logical_or(invalid, data == _FillValue)
    dataf = scale_factor * data + add_offset
    dataf[invalid] = np.nan
    dataf = np.ma.masked_where(np.isnan(dataf), dataf)
    
    # Get the geolocation data
    latitude = f['/VIIRS_Swath_LSTE/Geolocation Fields/latitude'][:]
    longitude = f['/VIIRS_Swath_LSTE/Geolocation Fields/longitude'][:]
        
    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon=180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90, 91, 45))
    m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
    m.scatter(longitude, latitude, c=dataf, s=1, cmap=plt.cm.jet,
              edgecolors=None, linewidth=0)
    cb = m.colorbar(location="bottom", pad='10%')    
    cb.set_label(units)

    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, long_name))
    fig = plt.gcf()
    # plt.show()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)

