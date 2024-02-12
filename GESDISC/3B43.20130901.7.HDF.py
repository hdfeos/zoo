"""

This example code illustrates how to access and visualize a GESDISC TRMM 3B43 
v7 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python 3B43.20130901.7.HDF.py

The HDF file must be in your current working directory.

Tested under: Python 2.7.13 :: Anaconda 4.3.22 
Last updated: 2017-12-15
"""
import os
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
from pyhdf.SD import SD, SDC

FILE_NAME = '3B43.20130901.7.HDF'
hdf = SD(FILE_NAME, SDC.READ)

DATAFIELD_NAME = 'precipitation'
ds = hdf.select(DATAFIELD_NAME)
data = ds[:,:].astype(np.float64)

# Handle attributes.
attrs = ds.attributes(full=1)
ua=attrs["units"]
units = ua[0]

# Consider 0 as the fill value.
data[data == 0.0] = np.nan

# You must create a masked array where nan is involved.
datam = np.ma.masked_where(np.isnan(data), data)
    
# The lat and lon should be calculated manually [1].
lat1d = np.arange(-49.875, 49.875, 0.249375)
lon1d = np.arange(-179.875, 179.876, 0.25)
longitude, latitude = np.meshgrid(lon1d, lat1d)
    
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
plt.title('{0}\n{1}'.format(basename, DATAFIELD_NAME))

fig = plt.gcf()
# plt.show()

pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)

    
# References
# [1] https://pmm.nasa.gov/sites/default/files/document_files/3B42_3B43_doc_V7.pdf
