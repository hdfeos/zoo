"""
This example code illustrates how to access and visualize POAM3 L2 HDF4 file
in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python poam3_ver4_sh_199808.hdf.v.py

The HDF file must be in your current working directory.


Tested under: Python 3.9.1::Miniconda
Last updated: 2022-05-20
"""

import os
import datetime

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from matplotlib import colors
from mpl_toolkits.basemap import Basemap
from pyhdf.SD import SD, SDC

FILE_NAME = 'poam3_ver4_sh_199808.hdf'
DATAFIELD_NAME = 'aerosol'
hdf = SD(FILE_NAME, SDC.READ)
        
# Read dataset.
w = 0 # 0 is for 0.355 nm wavelength. Change this for different wavelength.
data3D = hdf.select(DATAFIELD_NAME)
data = data3D[:,w,:]
attrs = data3D.attributes(full=1)
la=attrs["long_name"]
long_name = la[0]
ua=attrs["units"]
units = ua[0]
fva=attrs["_FillValue"]
fillvalue = fva[0]

# Set fillvalue and units.
data[data == fillvalue] = np.nan
datam = np.ma.masked_array(data, mask=np.isnan(data))

# Read dates.
date = hdf.select('date')
d = date[:]

# Read seconds.
sec = hdf.select('sec')
s = sec[:]

# Read wavelength.
wavelength = hdf.select('wavelength')
wave = wavelength[:]
attrs = wavelength.attributes(full=1)
wla=attrs["long_name"]
wlong_name = wla[0]
wa=attrs["units"]
wunits = wa[0]

# Read altitude.
altitude = hdf.select('z_aerosol')
alt = altitude[:]
attrs = altitude.attributes(full=1)
ala=attrs["long_name"]
along_name = ala[0]
ua=attrs["units"]
aunits = ua[0]

# Build date/time array.
h = np.floor(s / 3600.00)
i = 0
dt = []
for x in d:
  a = datetime.datetime(int(str(x)[:4]),int(str(x)[4:6]),int(str(x)[6:8]), int(h[i]))
  i = i+1
  dt.append(a)
  
# Contour the data on a grid of date/time vs. pressure
dates, altitude = np.meshgrid(dt, alt)
title = long_name + 'at ' + wlong_name + '=' + str(wave[w]) + '(' + wunits + ')'
basename = os.path.basename(FILE_NAME)
plt.contourf(dates, altitude, datam)
plt.gcf().autofmt_xdate()# makes labels easier to read
plt.title('{0}\n{1}'.format(basename, title))
plt.ylabel(along_name + '('+aunits+')')

fig = plt.gcf()
cb = plt.colorbar()
cb.set_label(units)

pngfile = "{0}.v.py.png".format(basename)
fig.savefig(pngfile)
