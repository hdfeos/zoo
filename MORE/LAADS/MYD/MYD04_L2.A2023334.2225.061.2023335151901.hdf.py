"""

This example code illustrates how to regrid a LAADS Aqua MODIS Swath
file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MYD04_L2.A2023334.2225.061.2023335151901.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2023-12-01
"""
import os

import cartopy.crs as ccrs
import matplotlib.pyplot as plt
import numpy as np
from netCDF4 import Dataset
from pyhdf.SD import SD, SDC

# Use $conda install -c conda-forge pyresample
from pyresample.geometry import GridDefinition, SwathDefinition
from pyresample.kd_tree import resample_nearest

FILE_NAME = "MYD04_L2.A2023334.2225.061.2023335151901.hdf"
DATAFIELD_NAME = "Optical_Depth_Land_And_Ocean"

# Open file.
hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data2D = hdf.select(DATAFIELD_NAME)
data = data2D[:, :].astype(np.double)

# Retrieve attributes.
attrs = data2D.attributes(full=1)
aoa = attrs["add_offset"]
add_offset = aoa[0]
fva = attrs["_FillValue"]
_FillValue = fva[0]
sfa = attrs["scale_factor"]
scale_factor = sfa[0]
ua = attrs["units"]
units = ua[0]
data[data == _FillValue] = np.nan
data = (data - add_offset) * scale_factor
ln = attrs["long_name"]
long_name = ln[0]

lat = hdf.select("Latitude")
latitude = lat[:, :]
lon = hdf.select("Longitude")
longitude = lon[:, :]

# Draw plot.
m = plt.axes(projection=ccrs.PlateCarree())
m.coastlines()
gls = m.gridlines(draw_labels=True)
gls.top_labels = False  # suppress top labels
gls.right_labels = False  # suppress right labels

p = plt.pcolormesh(longitude, latitude, data, transform=ccrs.PlateCarree())
cb = plt.colorbar(p)
cb.set_label(units)


# Put title using the first file.
basename = os.path.basename(FILE_NAME)
plt.title("{0}".format(basename))
m.text(-165.0, 30, long_name, size=8, transform=ccrs.PlateCarree())
fig = plt.gcf()

# Save image.
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)

# Regrid.

# Define SwathDefinition.
swathDef = SwathDefinition(lons=longitude, lats=latitude)

# Define GridDefinition.
# 0.1 degree is about 10.11km, which is close enough to native resolution.
cellSize = 0.1
min_lon = np.min(longitude)
max_lon = np.max(longitude)
min_lat = np.min(latitude)
max_lat = np.max(latitude)
x0, xinc, y0, yinc = (min_lon, cellSize, max_lat, -cellSize)
nx = int(np.floor((max_lon - min_lon) / cellSize))
ny = int(np.floor((max_lat - min_lat) / cellSize))
x = np.linspace(x0, x0 + xinc * nx, nx)
y = np.linspace(y0, y0 + yinc * ny, ny)
lon_g, lat_g = np.meshgrid(x, y)
grid_def = GridDefinition(lons=lon_g, lats=lat_g)

# Set radius_of_influence in meters.
ri = 10000
datag = resample_nearest(
    swathDef,
    data,
    grid_def,
    radius_of_influence=ri,
    epsilon=0.5,
    fill_value=np.nan,
)
[cols, rows] = datag.shape

# Save as netCDF.
_fname = FILE_NAME + ".nc4"
ncout = Dataset(_fname, "w", format="NETCDF4")

ncout.createDimension("lat", ny)
ncout.createDimension("lon", nx)

# Create latitude axis.
latg = ncout.createVariable("lat", np.dtype("double").char, ("lat"))
latg.standard_name = "latitude"
latg.long_name = "latitude"
latg.units = "degrees_north"
latg.axis = "Y"

# Create longitude axis.
long = ncout.createVariable("lon", np.dtype("double").char, ("lon"))
long.standard_name = "longitude"
long.long_name = "longitude"
long.units = "degrees_east"
long.axis = "X"

# Create variable array.
_varname = "aerosol_optical_depth_mean"
vout = ncout.createVariable(
    _varname, np.dtype("double").char, ("lat", "lon"), fill_value=_FillValue
)
_long_name = long_name
vout.long_name = _long_name
vout.units = units

# Copy axis from original dataset.
latg[:] = y[:]
long[:] = x[:]
vout[:] = datag[:]

# Close file.
ncout.close()
