"""

This example code illustrates how to access and visualize an OBPG MODIS Terra 
(MODIST) Swath HDF4 file in Python (PyHDF).

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python T2010001000000.L2_LAC_SST.hdf.z.py

The MODISA file must be in the same directory where this script resides.

Last Update: 2015-08-31

"""

import os
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np
from pyhdf.SD import SD, SDC

# Open HDF4 file.
FILE_NAME = 'T2010001000000.L2_LAC_SST.hdf'
hdf = SD(FILE_NAME, SDC.READ)


# Read dataset.
DATAFIELD_NAME='sst'
data = hdf.select(DATAFIELD_NAME)
lat = hdf.select('latitude')
latnp = lat[:,:]
lon = hdf.select('longitude')[:,:]
lonnp = lon[:,:]

# We need to blow up lat/lon values using control point columns parameter
# to match data size.

# Read global attributes
gattrs =  hdf.attributes(full=1)
nopcp = gattrs['Number of Pixel Control Points']
cpc = hdf.select('cntl_pt_cols')
step1 =  cpc[2] - cpc[1]
step2 = cpc[nopcp[0] - 1] - cpc[nopcp[0] - 2]

m = data.dim(0).length()
n = data.dim(1).length()

# We need to interpolate lat and lon to match the size of data.
longitude = np.zeros((m,n), dtype=np.float)
latitude = np.zeros((m,n), dtype=np.float)
    
for i in range (0,  m):
    for j in range (0,  nopcp[0]):
        if j == 0:
            latitude[i,j] = latnp[i,j]
            longitude[i,j] = lonnp[i,j]
            continue
        if j > 0 and j < nopcp[0]-1:
            # print 'step1='+str(step1)
            count=step1*(j-1)+1
            arr_fill=np.linspace(latnp[i,(j-1)], latnp[i, j], (step1+1))
            latitude[i, count:count+(step1)] = arr_fill[0:step1]
            arr_fill=np.linspace(lonnp[i,(j-1)], lonnp[i, j], (step1+1))
            longitude[i, count:count+(step1)] = arr_fill[0:step1]
            continue
        if j == nopcp[0]-1:
            count=step1*(j-1)+1 
            arr_fill=np.linspace(latnp[i,(j-1)], latnp[i, j], (step2+1)) 
            latitude[i, count:count+(step2)] = arr_fill[0:step2]
            arr_fill=np.linspace(lonnp[i,(j-1)], lonnp[i, j], (step2+1)) 
            longitude[i, count:count+(step2)] = arr_fill[0:step2]
            continue

dataf = data[:,:].astype(float)

# Handle fill value.
fv = -32767

dataf[dataf==fv] = np.nan
dataf = np.ma.masked_array(dataf, np.isnan(dataf))

attrs = data.attributes(full=1)
scale = attrs['slope']
offset = attrs['intercept']
dataf = dataf*scale[0] + offset[0]

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
m.pcolormesh(longitude, latitude, dataf, latlon=True)

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
pngfile = "{0}.z.py.png".format(FILE_NAME)
fig.savefig(pngfile)
