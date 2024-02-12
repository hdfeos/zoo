"""
Copyright (C) 2015 John Evans

This example code illustrates how to access and visualize a GES DISC OCO-2 
Swath HDF5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python oco2_L2StdND_03949a_150330_B8100r_170916014809.h5.py

The HDF file must be in your current working directory.

Tested under: Python 2.7.13 :: Anaconda 4.3.22 
Last updated: 2018-1-19
"""

import os
import h5py
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap


FILE_NAME = 'oco2_L2StdND_03949a_150330_B8100r_170916014809.h5'

with h5py.File(FILE_NAME, mode='r') as f:
    
    name = '/RetrievalResults/xco2'
    data = f[name][:]
    units = f[name].attrs['Units'][0] 
    longname = f[name].attrs['Description'][0]

    # Get the geolocation data
    latitude = f['/RetrievalGeometry/retrieval_latitude'][:]
    longitude = f['/RetrievalGeometry/retrieval_longitude'][:]

    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon=180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90, 91, 45))
    m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
    m.scatter(longitude, latitude, c=data, s=1, cmap=plt.cm.jet,
            edgecolors=None, linewidth=0)
    cb = m.colorbar(location="bottom", format='%.1e', pad='10%')
    cb.set_label(units)

    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, longname))
    fig = plt.gcf()

    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
