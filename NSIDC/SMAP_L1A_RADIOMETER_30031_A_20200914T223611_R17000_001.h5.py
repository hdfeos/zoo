"""
Copyright (C) 2015 John Evans

This example code illustrates how to access and visualize a SMAP L1A HDF5 file 
in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python SMAP_L1A_RADIOMETER_30031_A_20200914T223611_R17000_001.h5.py

The HDF file must be in your current working directory.

Tested under: Python 3.7.7 :: Anaconda custom (64-bit)
Last updated: 2020-09-15

"""

import os

import h5py
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np


def run(FILE_NAME):

    with h5py.File(FILE_NAME, mode='r') as f:

        name = '/HighResolution_Moments_Data/moments16_right_ascension'
        data = f[name][:]
        units = f[name].attrs['units']
        longname = f[name].attrs['long_name']
        _FillValue = f[name].attrs['_FillValue']
        valid_max = f[name].attrs['valid_max']
        valid_min = f[name].attrs['valid_min']        
        invalid = np.logical_or(data > valid_max,
                            data < valid_min)
        invalid = np.logical_or(invalid, data == _FillValue)
        data[invalid] = np.nan
        data = np.ma.masked_where(np.isnan(data), data)
        
        # Get the geolocation data
        latitude = f['/HighResolution_Moments_Data/moments16_lat'][:]
        longitude = f['/HighResolution_Moments_Data/moments16_lon'][:]

        
    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon=180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90, 91, 45))
    m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
    m.scatter(longitude, latitude, c=data, s=1, cmap=plt.cm.jet,
            edgecolors=None, linewidth=0)
    cb = m.colorbar(location="bottom", pad='10%')
    units = units.decode('ascii', 'replace')    
    cb.set_label(units)

    basename = os.path.basename(FILE_NAME)
    longname = longname.decode('ascii', 'replace')
    plt.title('{0}\n{1}'.format(basename, longname))
    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)

if __name__ == "__main__":
    hdffile = 'SMAP_L1A_RADIOMETER_30031_A_20200914T223611_R17000_001.h5'
    run(hdffile)
