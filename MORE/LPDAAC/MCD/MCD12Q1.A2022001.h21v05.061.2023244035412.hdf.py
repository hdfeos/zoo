"""
This example code illustrates how to access and visualize an LP DAAC MCD12Q1
v6 HDF-EOS2 Sinusoidal Grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python 


Tested under: Python 3.9.13 :: Miniconda (64-bit)
Last updated: 2024-06-06
"""
import os
import re
import pyproj

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from pyhdf.SD import SD, SDC
from mpl_toolkits.basemap import Basemap
from pyproj import Transformer

FILE_NAME = 'MCD12Q1.A2022001.h21v05.061.2023244035412.hdf'
DATAFIELD_NAME = 'LC_Prop3'
hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data3D = hdf.select(DATAFIELD_NAME)
data = data3D[:,:].astype(np.double)

# Read attributes.
attrs = data3D.attributes(full=1)
lna=attrs["long_name"]
print(lna)
long_name = lna[0]
long_name = long_name[0:19]
print(long_name)

vra=attrs["valid_range"]
valid_range = vra[0]
fva=attrs["_FillValue"]
_FillValue = fva[0]
print(_FillValue)

# Apply the attributes to the data.
invalid = np.logical_or(data < valid_range[0], data > valid_range[1])
invalid = np.logical_or(invalid, data == _FillValue)
data[invalid] = np.nan

# Construct the grid.  The needed information is in a global attribute
# called 'StructMetadata.0'.  Use regular expressions to tease out the
# extents of the grid.
fattrs = hdf.attributes(full=1)
ga = fattrs["StructMetadata.0"]
gridmeta = ga[0]
ul_regex = re.compile(r'''UpperLeftPointMtrs=\(
                          (?P<upper_left_x>[+-]?\d+\.\d+)
                          ,
                          (?P<upper_left_y>[+-]?\d+\.\d+)
                          \)''', re.VERBOSE)

match = ul_regex.search(gridmeta)
x0 = np.float64(match.group('upper_left_x'))
y0 = np.float64(match.group('upper_left_y'))

lr_regex = re.compile(r'''LowerRightMtrs=\(
                          (?P<lower_right_x>[+-]?\d+\.\d+)
                          ,
                          (?P<lower_right_y>[+-]?\d+\.\d+)
                          \)''', re.VERBOSE)
match = lr_regex.search(gridmeta)
x1 = np.float64(match.group('lower_right_x'))
y1 = np.float64(match.group('lower_right_y'))
print(x1)
print(y1)
nx, ny = data.shape
x = np.linspace(x0, x1, nx, endpoint=False)
y = np.linspace(y0, y1, ny, endpoint=False)
xv, yv = np.meshgrid(x, y)

# Define the source and destination projections.
# src_proj = pyproj.CRS("ESRI:54008")
# src_proj = pyproj.CRS("ESRI:53008")
# src_proj = pyproj.Proj("+proj=sinu +R=6371007.181 +nadgrids=@null +wktext")
# dst_proj = pyproj.CRS("EPSG:4326")
# xv, yv = np.meshgrid(lon, lat)


# Convert the coordinates.
# t = Transformer.from_crs(src_proj, dst_proj, always_xy=True)
# x, y = t.transform(xv, yv)

sinu = pyproj.Proj("+proj=sinu +R=6371007.181 +nadgrids=@null +wktext")
wgs84 = pyproj.Proj("EPSG:4326") 
lat, lon = pyproj.transform(sinu, wgs84, xv, yv)
# print(lon)

m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=-90,  urcrnrlat=90,
            llcrnrlon=-180, urcrnrlon=180)            
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 45))
m.drawmeridians(np.arange(-180, 180, 45), labels=[True, False, False, True])
# m.pcolormesh(lon, lat, data, latlon=True)
m.pcolormesh(lon, lat, data, latlon=True)
# m.pcolormesh(x, y, data.T, latlon=True)
# m.scatter(lon, lat, c=data, s=1,
#          cmap=plt.cm.jet,
#          edgecolors=None, linewidth=0)
cb = m.colorbar()

basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, long_name))
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
