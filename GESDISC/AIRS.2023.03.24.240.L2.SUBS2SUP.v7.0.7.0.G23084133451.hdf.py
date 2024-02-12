"""
This example code illustrates how to access and visualize a GESDISC AIRS swath
in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python AIRS.2023.03.24.240.L2.SUBS2SUP.v7.0.7.0.G23084133451.hdf.py

The HDF file must either be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-04-24
"""

import os

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np

from mpl_toolkits.basemap import Basemap
from pyhdf.SD import SD, SDC

FILE_NAME = 'AIRS.2023.03.24.240.L2.SUBS2SUP.v7.0.7.0.G23084133451.hdf'
DATAFIELD_NAME = 'olr'

hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data3D = hdf.select(DATAFIELD_NAME)
data = data3D[:,:]

# Read geolocation dataset.
lat = hdf.select('Latitude')
latitude = lat[:,:]
lon = hdf.select('Longitude')
longitude = lon[:,:]
        
    
# Replace the filled value with NaN, replace with a masked array.
data[data == -9999.0] = np.nan
datam = np.ma.masked_array(data, np.isnan(data))
    
m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=-90, urcrnrlat = 90,
            llcrnrlon=-180, urcrnrlon = 180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 30), labels=[True,False,False,False])
m.drawmeridians(np.arange(-180, 180, 45), labels=[False,False,False,True])
sc = m.scatter(longitude, latitude, c=data, s=0.1, cmap=plt.cm.jet,
                edgecolors=None, linewidth=0)
cb = m.colorbar()
# See [1]. The dataset doesn't have unit attribute.
units = 'W/m^2'
cb.set_label(units)
    
basename = os.path.basename(FILE_NAME)
plt.title('{0}\n {1}'.format(basename, DATAFIELD_NAME))
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
    
# Reference
#
# [1] https://airs.jpl.nasa.gov/data/products/v7-L2-L3/
