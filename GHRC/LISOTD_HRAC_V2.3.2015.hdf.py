"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize a GHRC HDF4 file in
Python.

If you have any questions, suggestions, or comments on this example, please 
use the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python LISOTD_HRAC_V2.3.2015.hdf.py

The HDF file must be in your current working directory.

Tested on: Python 3.7.4
Last Update: 2020/01/07

"""

import os
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from pyhdf.SD import SD, SDC
from mpl_toolkits.basemap import Basemap

FILE_NAME = 'LISOTD_HRAC_V2.3.2015.hdf'
DATAFIELD_NAME = 'HRAC_COM_FR'

hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
var = hdf.select(DATAFIELD_NAME)

# Retrieve attributes.
attrs = var.attributes(full=1)
fva=attrs["_FillValue"]
_FillValue = fva[0]   
ua=attrs["units"]
units = ua[0]
lna=attrs["long_name"]
long_name = lna[0]

lat = hdf.select('Latitude')
lon = hdf.select('Longitude')
latitude = lat[:]
longitude = lon[:]
    
data = var[:,:,0]
data[data == _FillValue] = np.nan
datam = np.ma.masked_array(data, np.isnan(data))

# Draw a southern polar stereographic projection using the low resolution
# coastline database.
m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=-90, urcrnrlat=90,
            llcrnrlon=-180, urcrnrlon=180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 45))
m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
m.pcolormesh(longitude, latitude, datam, latlon=True)

cb = m.colorbar()
cb.set_label(units)    

basename = os.path.basename(FILE_NAME)
long_name = long_name + ' at Day of year=0'
plt.title('{0}\n{1}'.format(basename, long_name))
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
    
