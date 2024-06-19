"""
This example code illustrates how to access and visualize an LP DAAC MCD12Q1
v6 HDF-EOS2 Sinusoidal Grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MCD12Q1_A2020.hdf.py

Tested under: Python 3.9.13 :: Miniconda (64-bit)
Last updated: 2024-06-18
"""

import os
import re

import matplotlib.pyplot as plt
import numpy as np
import pyproj
from mpl_toolkits.basemap import Basemap
from netCDF4 import Dataset
from pyhdf.SD import SD, SDC
from pyproj import Transformer
from pyresample.geometry import GridDefinition, SwathDefinition
from pyresample.kd_tree import resample_nearest

# A user contributed the following aggregated file.
FILE_NAME = "MCD12Q1_A2020.hdf"
DATAFIELD_NAME = "LC_Prop3"
hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data3D = hdf.select(DATAFIELD_NAME)
data = data3D[:, :].astype(np.double)

# Read attributes.
attrs = data3D.attributes(full=1)
lna = attrs["long_name"]
long_name = lna[0]
long_name = long_name[0:19]

vra = attrs["valid_range"]
valid_range = vra[0]
fva = attrs["_FillValue"]
_FillValue = fva[0]

# Apply the attributes to the data.
invalid = np.logical_or(data < valid_range[0], data > valid_range[1])
invalid = np.logical_or(invalid, data == _FillValue)
data[invalid] = np.nan

# Subset tundra (=51) only.
idx = data != 51
data[idx] = np.nan

# Construct the grid.  The needed information is in a global attribute
# called 'StructMetadata.0'.  Use regular expressions to tease out the
# extents of the grid.
fattrs = hdf.attributes(full=1)
ga = fattrs["StructMetadata.0"]
gridmeta = ga[0]
ul_regex = re.compile(
    r"""UpperLeftPointMtrs=\(
                          (?P<upper_left_x>[+-]?\d+\.\d+)
                          ,
                          (?P<upper_left_y>[+-]?\d+\.\d+)
                          \)""",
    re.VERBOSE,
)

match = ul_regex.search(gridmeta)
x0 = np.float64(match.group("upper_left_x"))
y0 = np.float64(match.group("upper_left_y"))

lr_regex = re.compile(
    r"""LowerRightMtrs=\(
                          (?P<lower_right_x>[+-]?\d+\.\d+)
                          ,
                          (?P<lower_right_y>[+-]?\d+\.\d+)
                          \)""",
    re.VERBOSE,
)
match = lr_regex.search(gridmeta)
x1 = np.float64(match.group("lower_right_x"))
y1 = np.float64(match.group("lower_right_y"))
ny, nx = data.shape
x = np.linspace(x0, x1, nx, endpoint=False)
y = np.linspace(y0, y1, ny, endpoint=False)
xv, yv = np.meshgrid(x, y)

# Define the source and destination projections.
src_proj = "+proj=sinu +R=6371007.181 +nadgrids=@null +wktext"
dst_proj = pyproj.CRS("EPSG:4326")

# Convert the coordinates.
t = Transformer.from_crs(src_proj, dst_proj, always_xy=True)
lon, lat = t.transform(xv, yv)

# Regrid.
#
# Define SwathDefinition.
swathDef = SwathDefinition(lons=lon, lats=lat)

# Define GridDefinition.
# 0.1 degree is about 10.11km.
cellSize = 0.1
min_lon = np.min(lon)
max_lon = np.max(lon)
min_lat = np.min(lat)
max_lat = np.max(lat)
x0, xinc, y0, yinc = (min_lon, cellSize, max_lat, -cellSize)
nx = int(np.floor((max_lon - min_lon) / cellSize))
ny = int(np.floor((max_lat - min_lat) / cellSize))
x = np.linspace(x0, x0 + xinc * nx, nx)
y = np.linspace(y0, y0 + yinc * ny, ny)
lon_g, lat_g = np.meshgrid(x, y)
grid_def = GridDefinition(lons=lon_g, lats=lat_g)

# Set radius_of_influence in meters.
ri = 10000
result = resample_nearest(
    swathDef,
    data,
    grid_def,
    radius_of_influence=ri,
    epsilon=0.5,
    fill_value=np.nan,
)
[cols, rows] = result.shape

# Check output using plot.
m = Basemap(projection="ortho", resolution="l", lat_0=90, lon_0=0)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 45))
m.drawmeridians(np.arange(-180, 180, 45), labels=[True, False, False, True])
m.pcolormesh(lon_g, lat_g, result, latlon=True)
cb = m.colorbar()

basename = os.path.basename(FILE_NAME)
plt.title("{0}\n{1}\n{2}".format(basename, long_name, "tundra"))
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)

# Save as netCDF.
_fname = FILE_NAME + ".nc4"
ncout = Dataset(_fname, "w", format="NETCDF4")

# Define axis size.
nlat = len(y)
nlon = len(x)
ncout.createDimension("lat", nlat)
ncout.createDimension("lon", nlon)

# Create latitude variable.
lat = ncout.createVariable("lat", np.dtype("float").char, ("lat"))
lat.standard_name = "latitude"
lat.long_name = "latitude"
lat.units = "degrees_north"
lat.axis = "Y"

# Create longitude variable.
lon = ncout.createVariable("lon", np.dtype("float").char, ("lon"))
lon.standard_name = "longitude"
lon.long_name = "longitude"
lon.units = "degrees_east"
lon.axis = "X"

# Create tundra variable.
_varname = "tundra"
vout = ncout.createVariable(
    _varname, np.dtype("float").char, ("lat", "lon"), fill_value=np.nan
)
_long_name = long_name + " (Tundra)"
vout.long_name = _long_name
vout.units = "None"

# Copy data from pyresample.
lon[:] = x[:]
lat[:] = y[:]
vout[:] = result[:]

# Close file.
ncout.close()
