"""
This example code illustrates how to access and visualize a LP DAAC MODIS swath
file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MOD021KM.A2023223.0455.061.2023223132259.hdf.py

The HDF files must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-08-17
"""
import os
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

USE_NETCDF4 = False
FILE_NAME = 'MOD14.A2023221.0750.061.2023221151516.hdf'
GEO_FILE_NAME = 'MOD03.A2023221.0750.061.2023221131337.hdf'
DATAFIELD_NAME = 'fire mask'

from pyhdf.SD import SD, SDC
hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data2D = hdf.select(DATAFIELD_NAME)
data = data2D[:,:].astype(np.double)

hdf_geo = SD(GEO_FILE_NAME, SDC.READ)

# Read geolocation dataset from MOD03 product.
lat = hdf_geo.select('Latitude')
latitude = lat[:,:]
lon = hdf_geo.select('Longitude')
longitude = lon[:,:]
        
# Retrieve attributes.
attrs = data2D.attributes(full=1)
lna=attrs["legend"]
long_name = lna[0]
vra=attrs["valid_range"]
valid_min = vra[0][0]        
valid_max = vra[0][1]        

        
invalid = np.logical_or(data > valid_max,
                        data < valid_min)
data[invalid] = np.nan
data = np.ma.masked_array(data, np.isnan(data))

# Find middle location.
lat_m = np.nanmean(latitude)
lon_m = np.nanmean(longitude)
lat_min = np.nanmin(latitude)
lat_max = np.nanmax(latitude)
lon_min = np.nanmin(longitude)
lon_max = np.nanmax(longitude)

# Render the plot in a lambert equal area projection.
m = Basemap(projection='laea', resolution='l', lat_ts=65,
            lat_0=lat_m, lon_0=lon_m,
            width=3000000, height=2500000)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(lat_min, lat_max, 10), labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(lon_min, lon_max, 10), labels=[0, 0, 0, 1])
m.scatter(longitude, latitude, c=data, s=1, cmap=plt.cm.jet,
           edgecolors=None, linewidth=0, latlon=True)
cb = m.colorbar()

# Exagerate dot size for fire locations.
idx = (data >= 7)
m.scatter(longitude[idx], latitude[idx], c=data[idx], s=3, cmap=plt.cm.jet,
           edgecolors=None, linewidth=0, latlon=True)
units = long_name[-77:]
cb.set_label(units, fontsize=8)

basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, DATAFIELD_NAME))
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
