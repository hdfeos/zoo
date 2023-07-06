"""
This example code illustrates how to access, visualize, and
 convert LaRC CALIPSO L3 HDF4 files into netCDF-4 in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python CAL_LID_L3_Tropospheric_APro_AllSky-Standard-V4-20.2007-01D.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-07-06
"""

import os

import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.basemap import Basemap
from netCDF4 import Dataset
from pyhdf.SD import SD, SDC

# Read December dataset first.
FILE_NAME = "CAL_LID_L3_Tropospheric_APro_AllSky-Standard-V4-20.2007-01D.hdf"
hdf = SD(FILE_NAME, SDC.READ)
# Print available datasets.
# print(hdf.datasets())

# Read dataset.
DATAFIELD_NAME = "Aerosol_Type"
dset = hdf.select(DATAFIELD_NAME)
data = dset[:].astype(np.double)
data = data[:, :, 100, 5]
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

# Read attributes.
attrs = dset.attributes(full=1)
ua = attrs["units"]
units = ua[0]

m = Basemap(
    projection="cyl",
    resolution="l",
    llcrnrlat=-90,
    urcrnrlat=90,
    llcrnrlon=-180,
    urcrnrlon=180,
)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 30), labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(-180, 181, 45), labels=[0, 0, 0, 1])
m.pcolormesh(longitude, latitude, data, latlon=True, shading="auto")
cb = m.colorbar()
cb.set_label(units)

long_name = (
    DATAFIELD_NAME
    + "[6]: elevated smoke histogram \n at Altitude="
    + str(altitude[100])
    + "km"
)
plt.title("{0}\n{1}".format(FILE_NAME, long_name), fontsize=8)
fig = plt.gcf()
basename = os.path.basename(FILE_NAME)
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)

# Save as netCDF.
_fname = FILE_NAME + ".nc4"
ncout = Dataset(_fname, "w", format="NETCDF4")

# Define axis size.
nlat = len(latitude)
nlon = len(longitude)
ncout.createDimension("lat", nlat)
ncout.createDimension("lon", nlon)

# Create latitude axis.
lat = ncout.createVariable("lat", np.dtype("double").char, ("lat"))
lat.standard_name = "latitude"
lat.long_name = "latitude"
lat.units = "degrees_north"
lat.axis = "Y"

# Create longitude axis.
lon = ncout.createVariable("lon", np.dtype("double").char, ("lon"))
lon.standard_name = "longitude"
lon.long_name = "longitude"
lon.units = "degrees_east"
lon.axis = "X"

# Create variable array.
_varname = "aerosol_type_elevated_smoke"
vout = ncout.createVariable(
    _varname, np.dtype("double").char, ("lat", "lon"), fill_value=fillvalue
)
_long_name = long_name
vout.long_name = _long_name
vout.units = units

# Copy axis from original dataset.
lon[:] = longitude[:]
lat[:] = latitude[:]
vout[:] = data[:]

# Close file.
ncout.close()
