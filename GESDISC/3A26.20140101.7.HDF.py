"""

This example code illustrates how to access and visualize a GESDISC TRMM 3A26 
v7 HDF4 Grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python 3A26.20140101.7.HDF.py

The HDF file must be in your current working directory.

Tested under: Python 2.7.13 :: Anaconda 4.3.22 
Last updated: 2017-12-18
"""
import os
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
from pyhdf.SD import SD, SDC

FILE_NAME = '3A26.20140101.7.HDF'
hdf = SD(FILE_NAME, SDC.READ)

DATAFIELD_NAME = 'rainMeanTH'
ds = hdf.select(DATAFIELD_NAME)
data = ds[0,:,:].astype(np.float64)
        
# Handle attributes.
attrs = ds.attributes(full=1)
ua=attrs["units"]
units = ua[0]
    
# Consider anything below 0.0 to be fill value.
# Must create a masked array where nan is involved.
data[data < 0.0] = np.nan
datam = np.ma.masked_where(np.isnan(data), data)
    
    
# The lat and lon should be calculated manually to match the grid size
# 72 x 16.
#
# The attribute "GridHeader" of "Grid" HDF4 vgroup has the following
# information:
#
# LatitudeResolution=5;
# LongitudeResolution=5;
# NorthBoundingCoordinate=40;
# SouthBoundingCoordinate=-40;
# EastBoundingCoordinate=180;
# WestBoundingCoordinate=-180;
# Origin=SOUTHWEST;
#
# You can check the above attribute information using HDFView.
latitude = np.arange(-40, 40, 5)
longitude = np.arange(-180, 180, 5)
    
# Draw an equidistant cylindrical projection using the low resolution
# coastline database.
m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=-90, urcrnrlat = 90,
            llcrnrlon=-180, urcrnrlon = 180)            
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 120, 30), labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(-180, 180, 45), labels=[0, 0, 0, 1])
m.pcolormesh(longitude, latitude, datam.T, latlon=True)
cb = m.colorbar()
cb.set_label(units)

basename = os.path.basename(FILE_NAME)
# nh3 dimension is the number of fixed heights [1].
plt.title('{0}\n{1} at nh3=0'.format(basename, DATAFIELD_NAME))

fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)

# References
#
# [1] https://pps.gsfc.nasa.gov/Documents/filespec.TRMM.V7.pdf

