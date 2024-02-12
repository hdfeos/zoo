"""

This example code illustrates how to access and visualize an LaRC MISR SOM
grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python MISR_AM1_GRP_ELLIPSOID_GM_P019_O067531_AN_F03_0024.hdf.py

 The file contains SOM projection. We need to use "eos2dump" to generate 1D 
 lat and lon and then convert them to 2D lat and lon accordingly.
 For example, run command as follows to get SOM projectoin lat/lon in ASCII.

 $eos2dump -c1 MISR_AM1_GRP_ELLIPSOID_GM_P019_O067531_AN_F03_0024.hdf BlueBand 50 > lat_MISR_AM1_GRP_ELLIPSOID_GM_P019_O067531_AN_F03_0024.output
 $eos2dump -c2 MISR_AM1_GRP_ELLIPSOID_GM_P019_O067531_AN_F03_0024.hdf BlueBand 50 > lon_MISR_AM1_GRP_ELLIPSOID_GM_P019_O067531_AN_F03_0024.output

The HDF file and HDF-EOS2 dumper output files for lat/lon must be in your 
current working directory.

Tested under: Python 2.7.13 :: Anaconda 4.3.22 
Last updated: 2017-12-13
"""

import os
import re
import matplotlib as mpl
import matplotlib.pyplot as plt
import mpl_toolkits.basemap.pyproj as pyproj
import numpy as np
from mpl_toolkits.basemap import Basemap
from pyhdf.SD import *

# Set file name to read.
FILE_NAME = 'MISR_AM1_GRP_ELLIPSOID_GM_P019_O067531_AN_F03_0024.hdf'

# Set dataset name to read.
DATAFIELD_NAME = 'Blue Radiance/RDQI'

# Open file.
hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data3D = hdf.select(DATAFIELD_NAME)

# We pick the 50th SOM block.
data = data3D[49,:,:]

# Read attributes.
attrs = data3D.attributes(full=1)
fva=attrs["_FillValue"]
_FillValue = fva[0]

# Read scale factor using HDFView.
# It is under /BlueBand/Grid Attributes/Scale factor.
scale_factor = 0.047203224152326584


# We need to shift bits for "RDQI" to get "Blue Band "only. 
# See the page 84 of "MISR Data Products Specifications (rev. S)".
# The document is available at [1].
datas = np.right_shift(data, 2);
dataf = datas.astype(np.double)

# Apply the fill value.
dataf[data == _FillValue] = np.nan

# Filter out values (> 16376) used for "Flag Data".
# See Table 1.2 in "MISR Level 1 Radiance Scaling and Conditioning
# Algorithm  Theoretical Basis" document [2].
dataf[datas > 16376] = np.nan
datam = np.ma.masked_array(dataf, mask=np.isnan(dataf))

# Apply scale facotr.
datam = scale_factor * datam;

# Read geolocation dataset from HDF-EOS2 dumper output.
GEO_FILE_NAME = 'lat_MISR_AM1_GRP_ELLIPSOID_GM_P019_O067531_AN_F03_0024.output'
lat = np.genfromtxt(GEO_FILE_NAME, delimiter=',', usecols=[0])
lat = lat.reshape(data.shape)
    
GEO_FILE_NAME = 'lon_MISR_AM1_GRP_ELLIPSOID_GM_P019_O067531_AN_F03_0024.output'
lon = np.genfromtxt(GEO_FILE_NAME, delimiter=',', usecols=[0])
lon = lon.reshape(data.shape)


# Set the limit for the plot.
m = Basemap(projection='cyl', resolution='h',
            llcrnrlat=np.min(lat), urcrnrlat = np.max(lat),
            llcrnrlon=np.min(lon), urcrnrlon = np.max(lon))
m.drawcoastlines(linewidth=0.5)
lat_sp = (np.max(lat)-np.min(lat)) / 4.0
m.drawparallels(np.arange(np.min(lat), np.max(lat), lat_sp), 
                labels=[1, 0, 0, 0])
lon_sp = (np.max(lon)-np.min(lon)) / 4.0
m.drawmeridians(np.arange(np.min(lon), np.max(lon), lon_sp), 
                labels=[0, 0, 0, 1])
m.pcolormesh(lon, lat, datam, latlon=True)
cb = m.colorbar()
pm = m.scatter(lon, lat, c=datam, s=1.0,  cmap=plt.cm.jet,
               edgecolors=None, linewidth=0)        
cb.set_label(r'$Wm^{-2}sr^{-1}{\mu}m^{-1}$')

basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, 'Blue Radiance'))
fig = plt.gcf()
a = fig.gca()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)

# References
# 
# [1] https://asdc.larc.nasa.gov/documents/misr/DPS_v50_RevS.pdf
# [2] https://eospso.gsfc.nasa.gov/sites/default/files/atbd/atbd-misr-01.pdf

    
