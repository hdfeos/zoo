"""
This example code illustrates how to access and visualize a LaRC CERES ES4
Aqua HDF4 Grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python CER_ES4_Aqua-Xtrk_Edition4_403409.202201.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-07-04
"""

import os

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from pyhdf.HDF import *
from pyhdf.V import *
from pyhdf.SD import SD, SDC

from mpl_toolkits.basemap import Basemap

FILE_NAME = 'CER_ES4_Aqua-Xtrk_Edition4_403409.202201.hdf'
VG_NAME = '2.5 Degree Regional'
VG2_NAME = 'Monthly (Day) Averages'
VG3_NAME = 'Total-Sky'
DATAFIELD_NAME = 'Longwave flux'

sd = SD(FILE_NAME, SDC.READ)

# We need to use Vgroup interface.
f = HDF(FILE_NAME, HC.READ)
v = f.vgstart()
vg = v.attach(v.find(VG_NAME))

members = vg.tagrefs()
for tag, ref in members:
    if tag == HC.DFTAG_VG:
        vg2 = v.attach(ref)
        if vg2._name == VG2_NAME:
            break
            
members = vg2.tagrefs()
for tag, ref in members:
    if tag == HC.DFTAG_VG:
        vg3 = v.attach(ref)
        if vg3._name == VG3_NAME: # Clear-Sky is another option.
            break

members = vg3.tagrefs()
for tag, ref in members:

    # SDS tag
    if tag == HC.DFTAG_NDG:
        sds = sd.select(sd.reftoindex(ref))
        name, rank, dims, type, nattrs = sds.info()
        
        if name == DATAFIELD_NAME:
            # Read dataset.
            data = sds[:]
            # Read attributes.
            attrs = sds.attributes(full=1)
            la=attrs["long_name"]
            long_name = la[0]
            ua=attrs["units"]
            units = ua[0]
            fva=attrs["_FillValue"]
            fillvalue = fva[0]
            
        if name == 'Colatitude':
            # Read dataset.
            latitude = sds[:]
            
        if name == 'Longitude':
            # Read dataset.
            longitude = sds[:]
           
sds.endaccess()
vg.detach()
v.end()
f.close()


# Set fillvalue and units.
data[data == fillvalue] = np.nan
datam = np.ma.masked_array(data, mask=np.isnan(data))

    
# Adjust lat/lon values.
latitude = 90 - latitude
longitude[longitude>180]=longitude[longitude>180]-360;
    
# The data is global, so render in a global projection.
m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=-90, urcrnrlat=90,
            llcrnrlon=-180, urcrnrlon=180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90.,90,45))
m.drawmeridians(np.arange(-180.,180,45), labels=[True,False,False,True])
m.pcolormesh(longitude, latitude, datam, latlon=True, shading='auto')
cb = m.colorbar()

cb.set_label(units)

basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, long_name))
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)

# Reference
#
# CER_ES9_NOAA20-FM6_Edition1_101109.202201.hdf.py

