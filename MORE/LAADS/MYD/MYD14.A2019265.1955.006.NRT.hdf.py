"""

This example code illustrates how to access and visualize a LAADS MYD14 NRT
HDF-EOS2 Swath file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MYD14.A2019265.1955.006.NRT.hdf.py

The HDF-EOS2 files must be in your current working directory.

Tested under: Python 3.7.3 :: Anaconda custom (64-bit)
Last updated: 2019-09-24
"""
import os
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
from pyhdf.SD import SD, SDC

FILE_NAME = 'MYD14.A2019265.1955.006.NRT.hdf'
GEO_FILE_NAME = 'MYD03.A2019265.1955.061.NRT.hdf'
DATAFIELD_NAME = 'fire mask'

# Open file.
hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data_raw = hdf.select(DATAFIELD_NAME)

# Subset data.
data = data_raw[:,:].astype(np.double)

# Open MYD03 geolocation file.
hdf_geo = SD(GEO_FILE_NAME, SDC.READ)

# Read geolocation dataset from MYD03 product.
lat = hdf_geo.select('Latitude')
latitude = lat[:,:]
lon = hdf_geo.select('Longitude')
longitude = lon[:,:]

        
# Retrieve attributes.
attrs = data_raw.attributes(full=1)
vra=attrs["valid_range"]
valid_min = vra[0][0]        
valid_max = vra[0][1]        
ua=attrs["legend"]
units = ua[0]

# Handle valid range
invalid = np.logical_or(data > valid_max,
                        data < valid_min)
data[invalid] = np.nan
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

# Legend attribute value is long with line feed character.
# Put colorbar at the bottom after removing line feed character.
units = units.replace("\n", " ")
cb = plt.colorbar(p, orientation="horizontal")
cb.set_label(units, fontsize=4)

basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, DATAFIELD_NAME), fontsize=10)
fig = plt.gcf()

    
# Save file.
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
    
