"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize a PO.DAAC AQUARIUS
SSS L2 Swath file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python Q2011280003000.L2_SCI_V5.0.h5.py

The HDF file must either be in your current working directory.

Last Update: 2019/10/18
"""

import os
import h5py
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

FILE_NAME = 'Q2011280003000.L2_SCI_V5.0.h5'
with h5py.File(FILE_NAME, mode='r') as f:

    datavar = f['/Aquarius Data/SSS']
    data = datavar[:,0]
    units = datavar.attrs['units'].decode()
    long_name = datavar.attrs['long_name'].decode()
    fv = datavar.attrs['_FillValue']
    print(fv)
    latitude = f['/Navigation/sclat'][:]
    longitude = f['/Navigation/sclon'][:]
    
    # Handle fill value.
    
    data[data == fv] = np.nan
    datam = np.ma.masked_array(data, np.isnan(data))
    
    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon=180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90, 91, 45))
    m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
    sc = m.scatter(longitude, latitude, c=datam, s=1, cmap=plt.cm.jet,
                   edgecolors=None, linewidth=0)

    cb = m.colorbar()
    cb.set_label(units)    

    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, long_name))
    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
