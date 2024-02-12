"""

This example code illustrates how to access and visualize a LAADS
MOD swath file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python MOD02QKM.A2012241.1610.006.2014218100922.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 2.7.13 :: Anaconda 4.3.22 
Last updated: 2017-12-13
"""

import os
import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.basemap import Basemap
from pyhdf.SD import SD, SDC

FILE_NAME = 'MOD02QKM.A2012241.1610.006.2014218100922.hdf'
DATAFIELD_NAME = 'EV_250_RefSB'

# Open file.
hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data3D = hdf.select(DATAFIELD_NAME)

# There are two ways to handle 250m resolution data, which is huge.
#
# The first method is to subsample data to match the provided Lat/Lon data.
#
# This method doesn't rely on HDF-EOS2 dumper outputs and plots at the 1/4
# resolution from the original.
#
# Just read the first level, and subset the data to match the lat/lon
# resolution.
# data = data3D[0,::4,::4].astype(np.double)
# lat = hdf.select('Latitude')
# lat = lat[:,:]
# lon = hdf.select('Longitude')
# lon = lon[:,:]

# The second method is to use HDF-EOS2 dumper to calculate full resolution
# lat/lon.
data = data3D[0,:,:].astype(np.double)

# Read geolocation dataset from HDF-EOS2 dumper output.
#
# Use the following command:
# $eos2dump -a1 MOD02QKM.A2012241.1610.006.2014218100922.hdf MODIS_SWATH_Type_L1B > lat_MOD02QKM.A2012241.1610.006.2014218100922.output
#
GEO_FILE_NAME = 'lat_MOD02QKM.A2012241.1610.006.2014218100922.output'
lat = np.genfromtxt(GEO_FILE_NAME, delimiter=',', usecols=[0])
lat = lat.reshape(data.shape)

# Use the following command:
#  $eos2dump -a2 MOD02QKM.A2012241.1610.006.2014218100922.hdf MODIS_SWATH_Type_L1B > lon_MOD02QKM.A2012241.1610.006.2014218100922.output
GEO_FILE_NAME = 'lon_MOD02QKM.A2012241.1610.006.2014218100922.output'
lon = np.genfromtxt(GEO_FILE_NAME, delimiter=',', usecols=[0])
lon = lon.reshape(data.shape)

# Retrieve attributes.
attrs = data3D.attributes(full=1)
lna=attrs["long_name"]
long_name = lna[0]
aoa=attrs["reflectance_offsets"]
add_offset = aoa[0][1]
fva=attrs["_FillValue"]
_FillValue = fva[0]
sfa=attrs["reflectance_scales"]
scale_factor = sfa[0][1]
vra=attrs["valid_range"]
valid_min = vra[0][0]        
valid_max = vra[0][1]        
ua=attrs["reflectance_units"]
units = ua[0]

# Retrieve dimension name.
dim = data3D.dim(0)
dimname = dim.info()[0]

# Handle fill value and min/max.
invalid = np.logical_or(data > valid_max,
                        data < valid_min)
invalid = np.logical_or(invalid, data == _FillValue)
data[invalid] = np.nan

# Apply scale and offset.
data = scale_factor * (data - add_offset)
data = np.ma.masked_array(data, np.isnan(data))

    
# For global map, you can use 'ortho' projection.
# We could run this script on 32G memory machine without subsampling on 
# global map.

lat_m = np.nanmean(lat)
lon_m = np.nanmean(lon)

# m = Basemap(projection='ortho', resolution='l', lat_0=lat_m, lon_0=lon_m)

# For zoomed map, you can use 'nplaea' projection.
#
# Subsample data. 32G memory is not enough for zoomed image.
# Increase stride size  if you don't see any plot.
stride = 10
data = data[::stride, ::stride]
lat = lat[::stride, ::stride]
lon = lon[::stride, ::stride]
m = Basemap(projection='nplaea', resolution='h',
            boundinglat=60.0, lon_0=lon_m)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90., 91., 30.), labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(-180, 181., 30), labels=[0, 0, 0, 1])

# You can try different plotting options - scatter, pcolormesh, contourf.
# Since your dataset is huge, plotting result may vary.
#
# m.scatter(lon, lat, c=data, s=1.0,  cmap=plt.cm.jet,
#          edgecolors=None, linewidth=0)

# m.pcolormesh(lon, lat, data, latlon=True)
m.contourf(lon, lat, data, latlon=True)
cb=m.colorbar()
cb.set_label(units)

basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}\nat {2}=0'.format(basename, 'Reflectance derived from ' + long_name, dimname), fontsize=10)
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
