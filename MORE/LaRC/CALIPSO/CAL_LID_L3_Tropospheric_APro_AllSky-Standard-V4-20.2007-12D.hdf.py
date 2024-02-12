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

    $python CAL_LID_L3_Tropospheric_APro_AllSky-Standard-V4-20.2007-12D.hdf.py

The HDF files must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-02-24
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
# Print available datasets.
# print(hdf.datasets())

# Read dataset.
DATAFIELD_NAME = "AOD_Mean"
dset = hdf.select(DATAFIELD_NAME)
data = dset[:].astype(np.double)

# Read geolocation datasets.
# They are all same for every file so we read only once.
lat = hdf.select("Latitude_Midpoint")
latitude = np.squeeze(lat[:])
lon = hdf.select("Longitude_Midpoint")
longitude = np.squeeze(lon[:])

# Apply the fill value.
fillvalue = -9999.0
data[data == fillvalue] = np.nan
data = np.ma.masked_array(data, np.isnan(data))
basename = os.path.basename(FILE_NAME)

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
    data_m = data_m + data

# We average data over 3 files.
data = data_m / 3.0

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

long_name = DATAFIELD_NAME + " 2007-2008 DJF"
plt.title("{0}\n{1}".format(fnames, long_name), fontsize=8)
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)

# Save as netCDF.
_fname = FILE_NAME + ".DJF.nc4"
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
_varname = "aerosol_optical_depth_mean"
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
