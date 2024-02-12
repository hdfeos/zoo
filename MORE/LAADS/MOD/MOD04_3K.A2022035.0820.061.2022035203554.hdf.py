"""

This example code illustrates how to regrid a LAADS MOD04_3K Swath
file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MOD04_3K.A2022035.0820.061.2022035203554.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2022-03-16
"""
import os

import cartopy.crs as ccrs
import cartopy.feature as cf
import cartopy.io.shapereader as shpreader
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import matplotlib.path as mpltPath

from cartopy.feature import ShapelyFeature
from mpl_toolkits.basemap import Basemap
from pyhdf.SD import SD, SDC

FILE_NAME = 'MOD04_3K.A2022035.0820.061.2022035203554.hdf'
DATAFIELD_NAME ='Optical_Depth_Land_And_Ocean'

# Open file.
hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data2D = hdf.select(DATAFIELD_NAME)
data = data2D[:,:].astype(np.double)

# Read geolocation dataset.
lat = hdf.select('Latitude')
latitude = lat[:,:]
lon = hdf.select('Longitude')
longitude = lon[:,:]

# Retrieve attributes.
attrs = data2D.attributes(full=1)
aoa=attrs["add_offset"]
add_offset = aoa[0]
fva=attrs["_FillValue"]
_FillValue = fva[0]
sfa=attrs["scale_factor"]
scale_factor = sfa[0]        
ua=attrs["units"]
units = ua[0]
data[data == _FillValue] = np.nan
data = (data - add_offset) * scale_factor

# Read shape file.
shpfilename = shpreader.natural_earth(resolution='10m',
                                      category='cultural',
                                      name='admin_0_countries')
reader = shpreader.Reader(shpfilename)

# Select Kenya shape.
for country in reader.records():
    if (country.attributes['NAME'][:5] == 'Kenya'):
        kenya = country

# Kenya has 2 polygons.
recs = len(kenya.geometry)
kpolygon=[]
for i in range(recs):
    g = kenya.geometry[i]
    for pt in list(g.exterior.coords):
        kpolygon.append(pt)

# Build Kenya boundary.        
path = mpltPath.Path(kpolygon)

# Find points inside Kenya boundary.
points = []
for latit in range(0,longitude.shape[0]):
    for lonit in range(0,longitude.shape[1]):
        point=(lon[latit,lonit],lat[latit,lonit])
        points.append(point)

# Create index.
inside=path.contains_points(points)
inside=np.array(inside).reshape(longitude.shape)
i=np.where(inside == True)

# Draw plot.
m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=-90, urcrnrlat = 90,
            llcrnrlon=-180, urcrnrlon = 180)
        
m.drawcoastlines(linewidth=0.5)
m.drawcountries(linewidth=0.5)
m.drawparallels(np.arange(-90., 120., 30.))
m.drawmeridians(np.arange(-180, 180., 45.))
m.scatter(longitude[i], latitude[i], c=data[i], s=1, cmap=plt.cm.jet,
          edgecolors=None, linewidth=0)
cb = m.colorbar()
cb.set_label(units)


# Put title using the first file.
basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, DATAFIELD_NAME))
fig = plt.gcf()

# Save image.
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
    
