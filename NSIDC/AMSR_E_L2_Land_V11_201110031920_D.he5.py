"""

This example code illustrates how to access and visualize an NSIDC AMSR-E
Land HDF-EOS5 Point data file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python AMSR_E_L2_Land_V11_201110031920_D.he5.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2021-06-08
"""

import os
import h5py

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from mpl_toolkits.basemap import Basemap

FILE_NAME = 'AMSR_E_L2_Land_V11_201110031920_D.he5'
DATA_NAME='/HDFEOS/POINTS/AMSR-E Level 2 Land Data/Data/Combined NPD and SCA Output Fields'
FIELD_NAME = 'SoilMoistureSCA'
with h5py.File(FILE_NAME, mode='r') as f:
    datas = f[DATA_NAME][:]
    latitude = datas[:]['Latitude']
    longitude = datas[:]['Longitude']
    data = datas[:][FIELD_NAME]
    _FillValue = -9999.0
    data[data == _FillValue] = np.nan
    data = np.ma.masked_array(data, np.isnan(data))

m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=-90, urcrnrlat=90,
            llcrnrlon=-170, urcrnrlon=190)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 45), labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(-180,181,45), labels=[0, 0, 0, 1])
m.scatter(longitude, latitude, c=data, s=1, cmap=plt.cm.jet,
          edgecolors=None, linewidth=0)
cb = m.colorbar()

basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, FIELD_NAME))
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)

