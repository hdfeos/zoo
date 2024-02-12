"""
This example code illustrates how to access and visualize a LaRC CERES ES9
NPP-FM5 HDF4 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python CER_ES9_NPP-FM5_Edition2_202209.201909.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2022-12-02
"""
import os

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from pyhdf.HDF import *
from pyhdf.V import *
from pyhdf.SD import SD, SDC
from mpl_toolkits.basemap import Basemap

# Open file.
FILE_NAME = 'CER_ES9_NPP-FM5_Edition2_202209.201909.hdf'

sd = SD(FILE_NAME, SDC.READ)

# You will not see all SDS datasets because the same variable name
# (e.g., Longwave Flux) was used under different Vgroups.
# print(sd.datasets())

# We need to use Vgroup interface.
f = HDF(FILE_NAME, HC.READ)
v = f.vgstart()
vg = v.attach(v.find('Hourbox Data'))

DATAFIELD_NAME = 'Longwave flux'

# Read the contents of the vgroup.
members = vg.tagrefs()
for tag, ref in members:
    # SDS tag
    if tag == HC.DFTAG_NDG:
        sds = sd.select(sd.reftoindex(ref))
        name, rank, dims, type, nattrs = sds.info()
        
        # print(name)
        # print(ref)
        
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
m.scatter(longitude, latitude, c=datam, s=1,
          cmap=plt.cm.jet, edgecolors=None, linewidth=0)
cb = m.colorbar()

cb.set_label(units)

basename = os.path.basename(FILE_NAME)

# This product has the long_name value that other datasets use.
# Disambiguate it by using HDF4 dataset name.
long_name = DATAFIELD_NAME + ' (' + long_name + ')'
plt.title('{0}\n{1}'.format(basename, long_name))
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
