"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize a LAADS MODIS swath
file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python MOD05_L2.A2010001.0000.006.2015041171924.hdf.py

The HDF files must be in your current working directory.

Tested under: Python 2.7.13 :: Anaconda 4.3.22 
Last updated: 2018-02-12
"""
import os
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

FILE_NAME = 'MOD05_L2.A2010001.0000.006.2015041171924.hdf'
GEO_FILE_NAME = 'MOD03.A2010001.0000.006.2012280165535.hdf'
DATAFIELD_NAME = 'Water_Vapor_Near_Infrared'

# To match the browse image, use the following dataset.
# DATAFIELD_NAME = 'Water_Vapor_Infrared'
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

# Use the following code for 'Water_Vapor_Infrared'.
# lat = hdf.select('Latitude')
# latitude = lat[:,:]
# lon = hdf.select('Longitude')
# longitude = lon[:,:]

# Retrieve attributes.
attrs = data2D.attributes(full=1)
lna=attrs["long_name"]
long_name = lna[0]
aoa=attrs["add_offset"]
add_offset = aoa[0]
fva=attrs["_FillValue"]
_FillValue = fva[0]
sfa=attrs["scale_factor"]
scale_factor = sfa[0]        
vra=attrs["valid_range"]
valid_min = vra[0][0]        
valid_max = vra[0][1]
ua=attrs["unit"]
# Use the following code for 'Water_Vapor_Infrared'.
# ua=attrs["units"]
units = ua[0]
        
invalid = np.logical_or(data > valid_max,
                        data < valid_min)
invalid = np.logical_or(invalid, data == _FillValue)
data[invalid] = np.nan
data = (data - add_offset) * scale_factor 
data = np.ma.masked_array(data, np.isnan(data))
# Find middle location.
lat_m = np.nanmean(latitude)
lon_m = np.nanmean(longitude)        
# Render the plot in a lambert equal area projection.
m = Basemap(projection='laea', resolution='l', lat_ts=65,
            lat_0=lat_m, lon_0=lon_m,
            width=3000000,height=2500000)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(50., 91., 10.), labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(-180, 181., 30), labels=[0, 0, 0, 1])
m.pcolormesh(longitude, latitude, data, latlon=True)
cb=m.colorbar()
cb.set_label(units, fontsize=8)

basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, long_name))
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
    