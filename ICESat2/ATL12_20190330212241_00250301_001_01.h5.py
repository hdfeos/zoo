"""

This example code illustrates how to access and visualize an NSIDC 
ICESat-2 ATL12 L2 HDF5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

   $python ATL12_20190330212241_00250301_001_01.h5.py

The HDF5 file must in your current working directory.

Tested under: Python 3.6.7 :: Anaconda custom (64-bit)
Last updated: 2019-08-05
"""

import os
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

import h5py

FILE_NAME = 'ATL12_20190330212241_00250301_001_01.h5'
with h5py.File(FILE_NAME, mode='r') as f:

    # We'll plot segment id to match [1].
    latvar = f['/gt1l/ssh_segments/latitude']
    latitude = latvar[:]
    
    lonvar = f['/gt1l/ssh_segments/longitude']
    longitude = lonvar[:]
    
    dset_name = '/gt1l/ssh_segments/stats/segment_id'
    datavar = f[dset_name]
    data = datavar[:]
    units = datavar.attrs['units']
    long_name = datavar.attrs['long_name']

    # Draw an equidistant cylindrical projection using the low resolution
    # coastline database.
    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat = 90,
                llcrnrlon=-180, urcrnrlon = 180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90., 120., 30.))
    m.drawmeridians(np.arange(-180, 180., 45.))
    m.scatter(longitude, latitude, c=data, s=1, cmap=plt.cm.jet,
              edgecolors=None, linewidth=0)
    cb = m.colorbar(location='bottom')
    units = units.decode('ascii', 'replace')        
    cb.set_label(units)
    basename = os.path.basename(FILE_NAME)
    long_name = long_name.decode('ascii', 'replace')        
    plt.title('{0}\n{1}\n{2}'.format(basename, dset_name, long_name))
    
    fig = plt.gcf()    
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)

# References
# [1] https://n5eil01u.ecs.nsidc.org/DP0/BRWS/Browse.001/2019.08.01/ATL12_20190330212241_00250301_001_01_BRW.gt1l.groundtrack.jpg?_ga=2.20335931.2080021204.1565031217-1341776255.1563991934