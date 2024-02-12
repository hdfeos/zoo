"""
This example code illustrates how to access and visualize a LaRC CERES SSF
NOAA20 FM6 VIIRS L2 netCDF-4/HDF5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python CER_SSF_NOAA20-FM6-VIIRS_Edition1B_100102.2022080123.nc.py

The netCDF-4/HDF5 file must either be in your current working directory.

Tested under: Python 3.9.12 :: Miniconda
Last updated: 2022-10-25

"""
import os
import h5py

import numpy as np

import matplotlib as mpl
import matplotlib.pyplot as plt

import cartopy.crs as ccrs

from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER

FILE_NAME = 'CER_SSF_NOAA20-FM6-VIIRS_Edition1B_100102.2022080123.nc'
with h5py.File(FILE_NAME, mode='r') as f:

    latvar = f['/Time_and_Position/instrument_fov_latitude']
    latitude = latvar[:]
    
    lonvar = f['/Time_and_Position/instrument_fov_longitude']
    longitude = lonvar[:]
    
    dset_name = '/TOA_and_Surface_Fluxes/toa_incoming_solar_radiation'
    datavar = f[dset_name]
    data = np.float32(datavar[:])
    units = datavar.attrs['units']
    units = units.decode('ascii', 'replace')
    
    long_name = datavar.attrs['long_name']
    long_name = long_name.decode('ascii', 'replace')
        
    _FillValue = datavar.attrs['_FillValue']
    
    # Handle fill values.
    data[data == _FillValue] = np.nan
    data = np.ma.masked_where(np.isnan(data), data)

    # Adjust lon values.
    longitude[longitude>180]=longitude[longitude>180]-360;
    lon = longitude
    lat = latitude
    
# Find the location that has the highest value.
i = np.unravel_index(data.argmax(), data.shape)
lat_m = lat[i]
lon_m = lon[i]

# Use ortho projection.
orth = ccrs.Orthographic(central_longitude=lon_m,
                         central_latitude=lat_m,
                         globe=None)

ax = plt.axes(projection=orth)
ax.set_global()

# Plot on map.
p = plt.scatter(lon, lat, c=data, s=1, cmap=plt.cm.jet,
                transform=ccrs.PlateCarree())
# Put grids.
gl = ax.gridlines()

# Put coast lines.
ax.coastlines()

# Put grid labels only at left and bottom.
gl.top_labels = False
gl.right_labels = False

# Put degree N/E label.
gl.xformatter = LONGITUDE_FORMATTER
gl.yformatter = LATITUDE_FORMATTER

# Adjust colorbar size and location using fraction and pad.
cb = plt.colorbar(p, fraction=0.022, pad=0.01)
cb.set_label(units, fontsize=8)

# Put title.
basename = os.path.basename(FILE_NAME)

plt.title('{0}\n{1}'.format(basename, long_name), fontsize=12)
fig = plt.gcf()

# Save image.
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
