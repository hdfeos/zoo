"""

This example code illustrates how to access, merge, average, visualize, and
 convert LaRC CALIPSO L3 HDF4 files into netCDF-4 in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python CAL_LID_L3_Tropospheric_APro_AllSky-Standard-V4-20.2007-12D.hdf.v.py

The HDF files must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-02-27
"""

import os
import glob

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from netCDF4 import Dataset
from pyhdf.SD import SD, SDC
from mpl_toolkits.basemap import Basemap

# Read December dataset first.
FILE_NAME = "CAL_LID_L3_Tropospheric_APro_AllSky-Standard-V4-20.2007-12D.hdf"
hdf = SD(FILE_NAME, SDC.READ)

# Read 3D dataset - 82(lat) x 72(lon) x 208(alt).
DATAFIELD_NAME = "Extinction_Coefficient_532_Mean" 
dset = hdf.select(DATAFIELD_NAME)
data = dset[:].astype(np.double)

# Read geolocation datasets.
# They are all same for every file so we read only once.
lat = hdf.select("Latitude_Midpoint")
latitude = np.squeeze(lat[:])

lon = hdf.select("Longitude_Midpoint")
longitude = np.squeeze(lon[:])

alt = hdf.select("Altitude_Midpoint")
altitude = np.squeeze(alt[:])

# Apply the fill value.
fillvalue = -9999.0
data[data == fillvalue] = np.nan
data = np.ma.masked_array(data, np.isnan(data))
basename = os.path.basename(FILE_NAME)

# Subset at Latitude = 38.
result = np.where(latitude == 38)
idx = result[0][0]
data = data[idx,:,:]

fnames = basename
# Open January & February 2008 files to calculate mean.
data_m = data
for file in sorted(
    glob.glob("CAL_LID_L3_Tropospheric_APro_AllSky-Standard-V4-20.2008-*.hdf")
):
    print(file)
    fnames = fnames + "\n" + os.path.basename(file)
    hdf = SD(file, SDC.READ)
    dset = hdf.select(DATAFIELD_NAME)
    data = dset[:].astype(np.double)
    # Apply the fill value.
    fillvalue = -9999.0
    data[data == fillvalue] = np.nan
    data = np.ma.masked_array(data, np.isnan(data))

    # Subset at Latitude = 38.
    data = data[idx,:,:]
    data_m = data_m + data

# We average data over 3 files.
data = data_m / 3.0

# Read attributes.
attrs = dset.attributes(full=1)
ua = attrs["units"]
units = ua[0]

# Contour the data on a grid of latitude vs. altitude
lon, alt = np.meshgrid(longitude, altitude)

plt.contourf(lon, alt, data.T)
cb = plt.colorbar()
cb.set_label(units)
long_name = DATAFIELD_NAME + " 2007-2008 DJF"
plt.title("{0}\n{1}".format(fnames, long_name), fontsize=8)
plt.xlabel('Longitude (degrees east)')
plt.ylabel('Altitude (km)')
fig = plt.gcf()
pngfile = "{0}.v.py.png".format(basename)
fig.savefig(pngfile)

# Save as netCDF.
_fname = FILE_NAME + ".DJF.v.nc4"
ncout = Dataset(_fname, "w", format="NETCDF4")

# Define axis size.
nalt = len(altitude)
nlon = len(longitude)
ncout.createDimension("alt", nalt)
ncout.createDimension("lon", nlon)

# Create altitude axis.
alt = ncout.createVariable("alt", np.dtype("double").char, ("alt"))
alt.standard_name = "altitude"
alt.long_name = "altitude"
alt.units = "km"
alt.axis = "Z"

# Create longitude axis.
lon = ncout.createVariable("lon", np.dtype("double").char, ("lon"))
lon.standard_name = "longitude"
lon.long_name = "longitude"
lon.units = "degrees_east"
lon.axis = "X"

# Create variable array.
_varname = "extinction_coefficient_532_mean"
vout = ncout.createVariable(
    _varname, np.dtype("double").char, ("alt", "lon"), fill_value=fillvalue
)
_long_name = long_name + " at 38N"
vout.long_name = _long_name
vout.units = units

# Copy axis from original dataset.
lon[:] = longitude[:]
alt[:] = altitude[:]
vout[:] = data.T[:]

# Close file.
ncout.close()
