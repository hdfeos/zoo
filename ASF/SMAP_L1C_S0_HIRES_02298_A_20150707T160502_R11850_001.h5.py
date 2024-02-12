"""
Copyright (C) 2015 John Evans

This example code illustrates how to access and visualize a SMAP L1C HDF5 file 
in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python SMAP_L1C_S0_HIRES_02298_A_20150707T160502_R11850_001.h5.py

The HDF file must either be in your current working directory or in a 
directory specified by the environment variable HDFEOS_ZOO_DIR.


Tested under: Python 2.7.10 :: Anaconda 2.2.0 (x86_64)
Last updated: 2016-04-05

"""

import os

import h5py
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

def run(FILE_NAME):
    
    with h5py.File(FILE_NAME, mode='r') as f:

        name = '/Sigma0_Data/cell_sigma0_hh_fore'
        data = f[name][:]
        units = 'None'
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
        latitude = f['/Sigma0_Data/cell_lat'][:]
        longitude = f['Sigma0_Data/cell_lon'][:]

        
    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon=180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90, 91, 45))
    m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
    m.scatter(longitude, latitude, c=data, s=1, cmap=plt.cm.jet,
            edgecolors=None, linewidth=0)
    cb = m.colorbar(location="bottom", pad='10%')    
    cb.set_label(units)

    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, longname))
    fig = plt.gcf()
    # plt.show()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)

if __name__ == "__main__":

    # If a certain environment variable is set, look there for the input
    # file, otherwise look in the current directory.
    hdffile = 'SMAP_L1C_S0_HIRES_02298_A_20150707T160502_R11850_001.h5'

    try:
        hdffile = os.path.join(os.environ['HDFEOS_ZOO_DIR'], hdffile)
    except KeyError:
        pass

    run(hdffile)
