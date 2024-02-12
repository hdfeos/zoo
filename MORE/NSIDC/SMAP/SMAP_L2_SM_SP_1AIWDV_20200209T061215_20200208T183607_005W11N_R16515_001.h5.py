"""

This example code illustrates how to access and visualize a SMAP L2 HDF5 file 
in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage: save this script and run

    $python SMAP_L2_SM_SP_1AIWDV_20200209T061215_20200208T183607_005W11N_R16515_001.h5.py

The HDF file must be in your current working directory.

Tested under: Python 3.7.3 :: Anaconda custom (64-bit)
Last updated: 2020-02-17
"""

import os

import h5py
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

FILE_NAME = 'SMAP_L2_SM_SP_1AIWDV_20200209T061215_20200208T183607_005W11N_R16515_001.h5'
    
with h5py.File(FILE_NAME, mode='r') as f:

    name = '/Soil_Moisture_Retrieval_Data_1km/soil_moisture_1km'
    data = f[name][:]
    units = f[name].attrs['units']
    units = units.decode('ascii', 'replace')
    long_name = f[name].attrs['long_name']
    long_name = long_name.decode('ascii', 'replace')
    _FillValue = f[name].attrs['_FillValue']
    valid_max = f[name].attrs['valid_max']
    valid_min = f[name].attrs['valid_min']        
    invalid = np.logical_or(data > valid_max,
                            data < valid_min)
    invalid = np.logical_or(invalid, data == _FillValue)
    data[invalid] = np.nan
    data = np.ma.masked_where(np.isnan(data), data)
        
    # Get the geolocation data
    lat = f['/Soil_Moisture_Retrieval_Data_1km/latitude_1km'][:]
    lon = f['/Soil_Moisture_Retrieval_Data_1km/longitude_1km'][:]

        
    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=np.min(lat), urcrnrlat = np.max(lat),
                llcrnrlon=np.min(lon), urcrnrlon = np.max(lon))
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(np.floor(np.min(lat)), np.ceil(np.max(lat)), 1),
                    labels=[1, 0, 0, 0])
    m.drawmeridians(np.arange(np.floor(np.min(lon)), np.ceil(np.max(lon)), 1),
                    labels=[0, 0, 0, 1])    
    m.scatter(lon, lat, c=data, s=1, cmap=plt.cm.jet,
            edgecolors=None, linewidth=0)
    cb = m.colorbar(location="bottom", pad='10%')    
    cb.set_label(units)

    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, long_name), fontsize=9)
    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
