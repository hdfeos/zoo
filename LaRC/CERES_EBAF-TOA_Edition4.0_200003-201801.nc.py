"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize a LaRC CERES EBAF
TOA Edition 4.0 netCDF-3 grid product in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python CERES_EBAF-TOA_Edition4.0_200003-201801.nc.py

The netCDF-3 file must either be in your current working directory
or in a directory specified by the environment variable HDFEOS_ZOO_DIR.

Tested under: Python 2.7.15 :: Anaconda custom (64-bit)
Last updated: 2018-06-25

"""

import os

import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

def run(FILE_NAME):

    # Identify the data field.
    DATAFIELD_NAME = 'toa_net_clr_mon'

    from netCDF4 import Dataset
    nc = Dataset(FILE_NAME)
    
    # List available variables.
    # print(nc)

    # Read data.
    var = nc.variables[DATAFIELD_NAME]
    data = var[0,:,:].astype(np.float64)
    latitude = nc.variables['lat'][:]
    longitude = nc.variables['lon'][:]

    # Read attributes.
    valid_min = np.float64(var.valid_min)
    valid_max = np.float64(var.valid_max)
    units = var.units
    long_name = var.long_name
    
    # Apply the valid_range attribute.
    invalid = np.logical_or(data < valid_min,
                            data > valid_max)
    data[invalid] = np.nan
    datam = np.ma.masked_array(data, mask=np.isnan(data))
    
    # The data is global, so render in a global projection.
    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon=180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90, 91, 30), labels=[1, 0, 0, 0])
    m.drawmeridians(np.arange(-180, 181, 45), labels=[0, 0, 0, 1])
    m.pcolormesh(longitude, latitude, datam, latlon=True)
    cb = m.colorbar()
    cb.set_label(units)

    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1} at time=0'.format(basename, long_name), fontsize=8)
    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
    
if __name__ == "__main__":

    # If a certain environment variable is set, look there for the input
    # file, otherwise look in the current directory.
    ncfile = 'CERES_EBAF-TOA_Edition4.0_200003-201801.nc'
    try:
        fname = os.path.join(os.environ['HDFEOS_ZOO_DIR'], ncfile)
    except KeyError:
        fname = ncfile

    run(fname)

