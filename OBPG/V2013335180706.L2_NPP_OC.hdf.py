"""

This example code illustrates how to access and visualize an OBPG VIIRS Swath 
HDF4 file in Python (PyHDF).

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python V2013335180706.L2_NPP_OC.hdf.py

The VIIRS file must be in the same directory where this script resides.

Last Update: 2015-09-01

"""

import os
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np
from pyhdf.SD import SD, SDC

# Open HDF4 file.
FILE_NAME = 'V2013335180706.L2_NPP_OC.hdf'
hdf = SD(FILE_NAME, SDC.READ)


# Read dataset.
DATAFIELD_NAME='chlor_a'
data = hdf.select(DATAFIELD_NAME)
lat = hdf.select('latitude')
latitude = lat[:,:]
lon = hdf.select('longitude')
longitude = lon[:,:]


# Handle fill value.
attrs = data.attributes(full=1)
fva = attrs['bad_value_scaled']
fv = fva[0] 
dataf = data[:,:].astype(float)
dataf[dataf==fv] = np.nan
dataf = np.ma.masked_array(dataf, np.isnan(dataf))

# Handle scale offset
scale = attrs['slope']
offset = attrs['intercept']
dataf = dataf*scale[0] + offset[0]

# Set custom levels for plot.
levels = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 1.0, 2.0, 4.0, 8.0, 16.0, 32.0]
cmap = plt.get_cmap('jet')
norm = mpl.colors.BoundaryNorm(levels, cmap.N)


# Draw an equidistant cylindrical projection using the low resolution
# coastline database.
latmin = np.min(latitude)
latmax = np.max(latitude)
lonmin = np.min(longitude)
lonmax = np.max(longitude)
m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=latmin, urcrnrlat = latmax,
            llcrnrlon=lonmin, urcrnrlon = lonmax)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(int(latmin), int(latmax), int((latmax-latmin)/3)), labels=[True,False,False,True])
m.drawmeridians(np.arange(int(lonmin), int(lonmax), int((lonmax-lonmin)/3)), labels=[True,False,False,True])
m.pcolormesh(longitude, latitude, dataf, latlon=True, cmap=cmap, norm=norm)

# Draw color bar.
cb = m.colorbar()
ua = attrs['units']
units = ua[0]
# Remove garbage character at the end.
cb.set_label('Unit: '+units[:-1])


lna=attrs["long_name"]
long_name = lna[0]
# Remove garbage character at the end.
plt.title('{0}\n {1}'.format(FILE_NAME, long_name[:-1]))
fig = plt.gcf()

# Save plot.
pngfile = "{0}.py.png".format(FILE_NAME)
fig.savefig(pngfile)
