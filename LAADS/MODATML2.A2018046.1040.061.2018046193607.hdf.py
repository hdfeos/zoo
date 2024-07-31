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

    $python MODATML2.A2018046.1040.061.2018046193607.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2024-07-30
"""
import os
import matplotlib as mpl
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
import numpy as np

FILE_NAME = 'MODATML2.A2018046.1040.061.2018046193607.hdf'
DATAFIELD_NAME = 'Cloud_Fraction'

from pyhdf.SD import SD, SDC
hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data_raw = hdf.select(DATAFIELD_NAME)
data = data_raw[:,:].astype(np.double)

# Read geolocation dataset.
lat = hdf.select('Latitude')
latitude = lat[:,:]
lon = hdf.select('Longitude')
longitude = lon[:,:]

# Retrieve attributes.
attrs = data_raw.attributes(full=1)
lna=attrs["long_name"]
long_name = lna[0]
aoa=attrs["add_offset"]
add_offset = aoa[0]
fva=attrs["_FillValue"]
_FillValue = fva[0]
sfa=attrs["scale_factor"]
scale_factor = sfa[0]        
ua=attrs["units"]
units = ua[0]

# Retrieve dimension name.
dim = data_raw.dim(0)
dimname = dim.info()[0]

data[data == _FillValue] = np.nan
data = (data - add_offset) * scale_factor 
datam = np.ma.masked_array(data, np.isnan(data))

# Find middle location.

lat_m = np.nanmean(latitude)
lon_m = np.nanmean(longitude)
# lat_m = lat[int(lat.shape[0]/2)]
# lon_m = lon[int(lon.shape[0]/2)]
    
# Use the following for Geographic projection.
# ax = plt.axes(projection=ccrs.PlateCarree())

# Let's use ortho projection.
orth = ccrs.Orthographic(central_longitude = lon_m,
                         central_latitude = lat_m,
                         globe=None)
ax = plt.axes(projection=orth)

# Remove the following to see zoom-in view.
ax.set_global()
p = plt.scatter(longitude, latitude, c=datam, s=1,
                transform=ccrs.PlateCarree(),
#                cmap=plt.cm.jet,
                edgecolors=None, linewidth=0)


# Gridline with draw_labels=True doesn't work on ortho.
# ax.gridlines(draw_labels=True)
ax.gridlines()
ax.coastlines()
cb = plt.colorbar(p)
cb.set_label(units, fontsize=8)

# Put title.
basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, long_name), fontsize=10)
fig = plt.gcf()

# Save image.
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
    
