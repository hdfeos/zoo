"""
This example code illustrates how to access and visualize a LAADS MODIS swath
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
Last updated: 2023-08-15
"""
import os
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

USE_NETCDF4 = False
FILE_NAME = 'MOD021KM.A2023223.0455.061.2023223132259.hdf'
GEO_FILE_NAME = 'MOD03.A2023223.0455.061.2023223112127.hdf'
DATAFIELD_NAME = 'EV_1KM_Emissive'

from pyhdf.SD import SD, SDC
hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data3D = hdf.select(DATAFIELD_NAME)

# Select Band 21. See reference [1].
data = data3D[1,:,:].astype(np.double)

hdf_geo = SD(GEO_FILE_NAME, SDC.READ)

# Read geolocation dataset from MOD03 product.
lat = hdf_geo.select('Latitude')
latitude = lat[:,:]
lon = hdf_geo.select('Longitude')
longitude = lon[:,:]
        
# Retrieve attributes.
attrs = data3D.attributes(full=1)
lna=attrs["long_name"]
long_name = lna[0]
aoa=attrs["radiance_offsets"]
add_offset = aoa[0]
fva=attrs["_FillValue"]
_FillValue = fva[0]
sfa=attrs["radiance_scales"]
scale_factor = sfa[0]        
vra=attrs["valid_range"]
valid_min = vra[0][0]        
valid_max = vra[0][1]        
ua=attrs["radiance_units"]
units = ua[0]
        
invalid = np.logical_or(data > valid_max,
                        data < valid_min)
invalid = np.logical_or(invalid, data == _FillValue)
data[invalid] = np.nan
data = (data - add_offset[1]) * scale_factor[1]
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
cb.set_label(units, fontsize=8)

basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, 'Band 21 Radiance from ' + long_name))
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
    
# Reference
#
# [1] http://ocean.stanford.edu/gert/easy/bands.html
