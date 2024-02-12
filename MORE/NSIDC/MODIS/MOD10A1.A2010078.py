"""

This example code illustrates how to access, merge, and visualize
an NSIDC MODIS grid files in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MOD10A1.A2010078.py

The HDF files must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-04-05
"""
import os
import glob
import re

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np

from mpl_toolkits.basemap import Basemap
from pyhdf.SD import SD, SDC
from pyproj import Transformer

FILE_NAME = 'MOD10A1.A2010078'
DATAFIELD_NAME = 'Snow_Albedo_Daily_Tile'

i = 0

# Read 2010 day 078 data only.
for file in sorted(glob.glob(FILE_NAME+'*.hdf')): 

    print(file)
    
    reader = open(file)
    hdf = SD(file, SDC.READ)
    
    # Read dataset.
    data2D = hdf.select(DATAFIELD_NAME)
    data = data2D[:,:].astype(np.double)
    
    # Retrieve attributes.
    attrs = data2D.attributes(full=1)
    fva=attrs["_FillValue"]
    _FillValue = fva[0]
    ua=attrs["units"]
    units = ua[0]
    data[data == _FillValue] = np.nan
    datam = np.ma.masked_array(data, np.isnan(data))
    if i == 0 :
        data_m = datam
    else:
        data_m = np.vstack([data_m, datam])
        

    # Read global attribute.
    fattrs = hdf.attributes(full=1)
    ga = fattrs["StructMetadata.0"]
    gridmeta = ga[0]

                
    # Construct the grid.  The needed information is in a global attribute
    # called 'StructMetadata.0'.  Use regular expressions to tease out the
    # extents of the grid. 
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
    ny, nx = data.shape
    xinc = (x1 - x0) / nx
    yinc = (y1 - y0) / ny

    x = np.linspace(x0, x0 + xinc*nx, nx)
    y = np.linspace(y0, y0 + yinc*ny, ny)
    xv, yv = np.meshgrid(x, y)

    sinu = '+proj=sinu +R=6371007.181 +nadgrids=@null +wktext'
    t = Transformer.from_crs(sinu, "epsg:4326", always_xy=True)
    lon, lat= t.transform(xv, yv)

    # There's a wraparound issue for the longitude,
    # as part of the tile extends over the international dateline,
    # and pyproj wraps longitude values west
    # of 180W (< -180) into positive territory.
    # Basemap's pcolormesh method doesn't like that.
    lon[lon > 0] -= 360
    
    latitude = lat[:,:]
    longitude = lon[:,:]
    if i == 0 :
        latitude_m = latitude
        longitude_m = longitude
    else:
        latitude_m = np.vstack([latitude_m, latitude])
        longitude_m = np.vstack([longitude_m, longitude])
        
    i = i + 1

# Use Greenlad boundary [1].
m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=50, urcrnrlat=90,
            llcrnrlon=-80, urcrnrlon=-10)

m.drawcoastlines(linewidth=0.5)
# labels = [left,right,top,bottom]
m.drawparallels(np.arange(50, 90, 10), labels=[True,False,False,False])
m.drawmeridians(np.arange(-80, -10, 10), labels=[False,False,False,True])
sc = m.scatter(longitude_m, latitude_m, c=data_m, s=0.1, cmap=plt.cm.jet,
               edgecolors=None, linewidth=0)
cb = m.colorbar()
cb.set_label(units)


# Put title using the common prefix.
basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, DATAFIELD_NAME))
fig = plt.gcf()

# Save image.
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
    

# Reference
# [1] https://en.wikipedia.org/wiki/Greenland
