"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize a LAADS MYD021KM v6
HDF-EOS2 Swath file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python MYD021KM.A2002226.0000.006.2012033082925.hdf.py

The HDF-EOS2 files must be in your current working directory.

Tested under: Python 2.7.13 :: Anaconda 4.3.22 
Last updated: 2018-02-16
"""
import os
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
from pyhdf.SD import SD, SDC

FILE_NAME = 'MYD021KM.A2002226.0000.006.2012033082925.hdf'
GEO_FILE_NAME = 'MYD03.A2002226.0000.006.2012033081943.hdf'
DATAFIELD_NAME = 'EV_1KM_Emissive'

# Open file.
hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data_raw = hdf.select(DATAFIELD_NAME)

# Subset data.
data = data_raw[0,:,:].astype(np.double)

# Open MYD03 geolocation file.
hdf_geo = SD(GEO_FILE_NAME, SDC.READ)

# Read geolocation dataset from MYD03 product.
lat = hdf_geo.select('Latitude')
latitude = lat[:,:]
lon = hdf_geo.select('Longitude')
longitude = lon[:,:]
        
# Retrieve attributes.
attrs = data_raw.attributes(full=1)
lna=attrs["long_name"]
long_name = lna[0]
aoa=attrs["radiance_offsets"]
add_offset = aoa[0][0]
fva=attrs["_FillValue"]
_FillValue = fva[0]
sfa=attrs["radiance_scales"]
scale_factor = sfa[0][0]        
vra=attrs["valid_range"]
valid_min = vra[0][0]        
valid_max = vra[0][1]        
ua=attrs["radiance_units"]
units = ua[0]

# Retrieve dimension name.
dim = data_raw.dim(0)
dimname = dim.info()[0]

invalid = np.logical_or(data > valid_max,
                        data < valid_min)
invalid = np.logical_or(invalid, data == _FillValue)
data[invalid] = np.nan
data = (data - add_offset) * scale_factor 
data = np.ma.masked_array(data, np.isnan(data))

# Find middle location.
lat_m = np.nanmean(latitude)
lon_m = np.nanmean(longitude)

# Let's use ortho projection.
orth = ccrs.Orthographic(central_longitude=lon_m,
                         central_latitude=lat_m,
                         globe=None)
ax = plt.axes(projection=orth)

# Set global view. You can comment it out to get zoom-in view.
ax.set_global()

# If you want to get global view, you need to subset.
p = plt.pcolormesh(longitude[::5][::5],
                   latitude[::5][::5],
                   data[::5][::5],
                   transform=ccrs.PlateCarree())

# The following works if global view is turned off.
# p = plt.pcolormesh(longitude, latitude, data, transform=ccrs.PlateCarree())

# Gridline with draw_labels=True doesn't work on Ortho projection.
# ax.gridlines(draw_labels=True)
ax.gridlines()
ax.coastlines()
cb = plt.colorbar(p)
cb.set_label(units, fontsize=8)

basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}\nat {2}=0'.format(basename,
                            'Radiance derived from ' + long_name, dimname),
          fontsize=10)
fig = plt.gcf()

# Save file.
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
    
