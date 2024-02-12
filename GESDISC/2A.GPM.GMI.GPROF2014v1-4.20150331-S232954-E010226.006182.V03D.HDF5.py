"""
Copyright (C) 2016 John Evans

This example code illustrates how to access and visualize a GPM L2 HDF5 file 
in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python 2A.GPM.GMI.GPROF2014v1-4.20150331-S232954-E010226.006182.V03D.HDF5.py

The HDF file must either be in your current working directory or in a 
directory specified by the environment variable HDFEOS_ZOO_DIR.

Tested under: Python 2.7.10 :: Anaconda 2.2.0 (x86_64)
Last updated: 2016-01-07

"""

import os

import h5py
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

# Reduce font size because file name is long.
mpl.rcParams.update({'font.size': 10})

def run(FILE_NAME):
    
    with h5py.File(FILE_NAME, mode='r') as f:

        name = '/S1/surfacePrecipitation'
        data = f[name][:]
        units = f[name].attrs['Units']
        # The attribute says -9999.900391 but data uses -9999.0.
        # _FillValue = f[name].attrs['CodeMissingValue']
        _FillValue = -9999.0
        data[data == _FillValue] = np.nan
        data = np.ma.masked_where(np.isnan(data), data)
        
        # Get the geolocation data
        latitude = f['/S1/Latitude'][:]
        longitude = f['/S1/Longitude'][:]

        
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
    plt.title('{0}\n{1}'.format(basename, name))
    fig = plt.gcf()
    # plt.show()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)

if __name__ == "__main__":

    # If a certain environment variable is set, look there for the input
    # file, otherwise look in the current directory.
    hdffile = '2A.GPM.GMI.GPROF2014v1-4.20150331-S232954-E010226.006182.V03D.HDF5'

    try:
        hdffile = os.path.join(os.environ['HDFEOS_ZOO_DIR'], hdffile)
    except KeyError:
        pass

    run(hdffile)
