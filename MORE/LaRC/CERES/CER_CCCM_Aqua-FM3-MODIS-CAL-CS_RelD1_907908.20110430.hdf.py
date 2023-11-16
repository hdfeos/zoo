"""
This example code illustrates how to access and visualize a LaRC CERES CCCM
Aqua-FM3-MODIS-CAL_CS HDF4 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python CER_CCCM_Aqua-FM3-MODIS-CAL-CS_RelD1_907908.20110430.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2023-11-16
"""
import os

import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.basemap import Basemap
from netCDF4 import Dataset
from pyhdf.SD import SD, SDC
from pyresample.geometry import GridDefinition, SwathDefinition
from pyresample.kd_tree import resample_nearest

# Open file.
FILE_NAME = "CER_CCCM_Aqua-FM3-MODIS-CAL-CS_RelD1_907908.20110430.hdf"

hdf = SD(FILE_NAME, SDC.READ)
# print(sd.datasets())

# Read dataset.
DATAFIELD_NAME = "Surface pressure"
dset = hdf.select(DATAFIELD_NAME)
data = dset[:].astype(np.double)

# Read geolocation datasets.
lat = hdf.select("Colatitude of CERES FOV at surface")
latitude = lat[:]
lon = hdf.select("Longitude of CERES FOV at surface")
longitude = lon[:]

# Read attributes.
attrs = dset.attributes(full=1)
ua = attrs["units"]
units = ua[0]
fva = attrs["_FillValue"]
fillvalue = fva[0]

# Apply the fill value attribute.
data[data == fillvalue] = np.nan
data = np.ma.masked_array(data, np.isnan(data))

# Adjust lat/lon values.
latitude = 90 - latitude
longitude[longitude > 180] = longitude[longitude > 180] - 360

# Subset valid data.
idx = np.where((latitude >= -90.0) & (latitude <= 90.0))

# The data is global, so render in a global projection.
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
sc = m.scatter(
    longitude[idx],
    latitude[idx],
    c=data[idx],
    s=1,
    cmap=plt.cm.jet,
    edgecolors=None,
    linewidth=0,
)
cb = m.colorbar()
cb.set_label(units)

basename = os.path.basename(FILE_NAME)
long_name = DATAFIELD_NAME
plt.title("{0}\n{1}".format(basename, long_name))
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)

# Resample data.
# 0.1 degree is about 10.11km.
cellSize = 0.1

# Set radius_of_influence in meters.
ri = 10000

# Set bounds.
latbounds = [-90.0, 90.0]
lonbounds = [-180.0, 180.0]

min_lon = lonbounds[0]
max_lon = lonbounds[1]
min_lat = latbounds[0]
max_lat = latbounds[1]
x0, xinc, y0, yinc = (min_lon, cellSize, max_lat, -cellSize)
nx = int(np.floor((max_lon - min_lon) / cellSize))
ny = int(np.floor((max_lat - min_lat) / cellSize))
x = np.linspace(x0, x0 + xinc * nx, nx)
y = np.linspace(y0, y0 + yinc * ny, ny)
lon_g, lat_g = np.meshgrid(x, y)
grid_def = GridDefinition(lons=lon_g, lats=lat_g)
swath_def = SwathDefinition(lons=longitude, lats=latitude)
datag = resample_nearest(
    swath_def,
    data,
    grid_def,
    radius_of_influence=ri,
    epsilon=0.5,
    fill_value=np.nan,
)

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
    _varname, np.dtype("double").char, ("lat", "lon"), fill_value=fillvalue
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
