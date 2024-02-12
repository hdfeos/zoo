"""

This example code illustrates how to access and visualize a OBPG SeaWiFS Swath 
HDF4 file in Python (PyHDF).

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python S1997247162631.L2_MLAC_OC.hdf.py

The HDF4 file must be in your current working directory where the Python script
resides.

Last Update: 2015-08-31

"""

import os
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np
from pyhdf.SD import SD, SDC

# Open HDF4 file.
FILE_NAME = 'S1997247162631.L2_MLAC_OC.hdf'
hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
DATAFIELD_NAME='Rrs_412'
data = hdf.select(DATAFIELD_NAME)
lat = hdf.select('latitude')
latitude = lat[:,:]
lon = hdf.select('longitude')
longitude = lon[:,:]


# Handle fill value.
dataf = data[:,:].astype(float)
fv = -32767
dataf[dataf==fv] = np.nan
dataf = np.ma.masked_array(dataf, np.isnan(dataf))

# Handle scale offset
attrs = data.attributes(full=1)
scale = attrs['slope']
offset = attrs['intercept']
dataf = dataf*scale[0] + offset[0]

# Draw an equidistant cylindrical projection using the low resolution
# coastline database.
m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=-90, urcrnrlat = 90,
            llcrnrlon=-180, urcrnrlon = 180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 45))
m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
m.pcolormesh(longitude, latitude, dataf, latlon=True)


# Draw color bar.
cb = m.colorbar()
ua = attrs['units']
units = ua[0]
# Remove garbage character at the end.
cb.set_label('Unit: '+units[:-1])

# Draw title.
lna=attrs["long_name"]
long_name = lna[0]
# Remove garbage character at the end.
plt.title('{0}\n {1}'.format(FILE_NAME, long_name[:-1]))
fig = plt.gcf()

# Save plot.
pngfile = "{0}.py.png".format(FILE_NAME)
fig.savefig(pngfile)
