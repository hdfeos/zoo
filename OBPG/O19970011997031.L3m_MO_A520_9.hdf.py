"""

This example code illustrates how to access and visualize a OBPG OCTS Grid 
HDF4 file in Python (PyHDF).

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python O19970011997031.L3m_MO_A520_9.hdf.py

The OCTS file must be in your current working directory.

Last Update: 2015-08-31

"""

import os
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np
from pyhdf.SD import SD, SDC

# Open HDF4 file.
FILE_NAME = 'O19970011997031.L3m_MO_A520_9.hdf'
hdf = SD(FILE_NAME, SDC.READ)

# List available SDS datasets.
# print hdf.datasets()

# The lat and lon should be calculated using lat and lon of southwest point.
# Then, we need number of lines and columns to calculate the lat and lon
# step. Assume even space between lat and lon points to get all lat and lon
# data.
# Extract southwest point from global attribute.
gattrs =  hdf.attributes(full=1)
swlata = gattrs['SW Point Latitude']
swlat = swlata[0]
swlona = gattrs['SW Point Longitude']
swlon = swlona[0]
linesa = gattrs['Number of Lines']
nlat = linesa[0]
colsa = gattrs['Number of Columns']
nlon = colsa[0]
latstepa = gattrs['Latitude Step']
latstep = latstepa[0]
lonstepa = gattrs['Longitude Step']
lonstep = lonstepa[0]

nmlat = swlat + (nlat)*latstep;
emlon = swlon + (nlon)*lonstep;

longitude = np.r_[nmlat :  swlat : (-latstep)]
latitude =  np.r_[swlon :  emlon : (lonstep)]

# Read dataset.
DATAFIELD_NAME='l3m_data'
data = hdf.select(DATAFIELD_NAME)

# Handle fill value [1].
fv = 255
dataf = data[:,:].astype(float)
dataf[dataf==fv] = np.nan
dataf = np.ma.masked_array(dataf, np.isnan(dataf))

# Handle scale offset
attrs = data.attributes(full=1)
scale = attrs['Slope']
offset = attrs['Intercept']
dataf = dataf*scale[0] + offset[0]

# Draw an equidistant cylindrical projection using the low resolution
# coastline database.
m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=-90, urcrnrlat = 90,
            llcrnrlon=-180, urcrnrlon = 180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 45))
m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
m.pcolormesh(latitude, longitude, dataf, latlon=True)

# Draw color bar.
cb = m.colorbar()
units = 'None'
cb.set_label('Unit: '+units)

# Draw title.
lna=gattrs['Parameter']
long_name = lna[0]
# Remove garbage character at the end.
plt.title('{0}\n {1}'.format(FILE_NAME, long_name[:-1]))
fig = plt.gcf()

# Save plot.
pngfile = "{0}.py.png".format(FILE_NAME)
fig.savefig(pngfile)

# Reference
# [1] http://oceancolor.gsfc.nasa.gov/DOCS/Ocean_Level-3_SMI_Products.pdf
