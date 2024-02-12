"""

This example code illustrates how to regrid a LAADS MODIS swath
file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MOD04_L2_regrid.py

The HDF file must be in your current working directory.

Tested under: Python 3.7.7 :: Anaconda custom (64-bit)
Last updated: 2021-03-01
"""
import os

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import cartopy.crs as ccrs

from pyhdf.SD import SD, SDC

# Use $conda install -c conda-forge pyresample
from pyresample import kd_tree,geometry
from pyresample.plot import area_def2basemap
from pyresample import load_area, save_quicklook 
from pyresample.geometry import GridDefinition, SwathDefinition
from pyresample.kd_tree import resample_nearest

# For GeoTIFF generation
from osgeo import gdal, osr

FILE_NAME = 'MOD04_L2.A2015014.1335.006.2015034193531.hdf'
DATAFIELD_NAME = 'Optical_Depth_Land_And_Ocean'

# Open file.
hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data2D = hdf.select(DATAFIELD_NAME)
data = data2D[:,:].astype(np.double)

# Read geolocation dataset.
lat = hdf.select('Latitude')
latitude = lat[:,:]
lon = hdf.select('Longitude')
longitude = lon[:,:]

# Retrieve attributes.
attrs = data2D.attributes(full=1)
aoa=attrs["add_offset"]
add_offset = aoa[0]
fva=attrs["_FillValue"]
_FillValue = fva[0]
sfa=attrs["scale_factor"]
scale_factor = sfa[0]        
ua=attrs["units"]
units = ua[0]
data[data == _FillValue] = np.nan
data = (data - add_offset) * scale_factor

# Draw plot.
m = plt.axes(projection=ccrs.PlateCarree())
m.coastlines()
m.gridlines()
p = plt.pcolormesh(longitude, latitude, data, transform=ccrs.PlateCarree())
cb = plt.colorbar(p)
cb.set_label(units)


# Put title using the first file.
basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, DATAFIELD_NAME))
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
x = np.linspace(x0, x0 + xinc*nx, nx)
y = np.linspace(y0, y0 + yinc*ny, ny)
lon_g, lat_g = np.meshgrid(x, y)
grid_def = GridDefinition(lons=lon_g, lats=lat_g)

# Set radius_of_influence in meters.
ri = 10000
result = resample_nearest(swathDef, data, grid_def, 
                          radius_of_influence=ri, epsilon=0.5,
                          fill_value=np.nan)
[cols, rows] = result.shape

# Check the grid using GeoTIFF and QGIS.
driver = gdal.GetDriverByName("GTiff")
outdata = driver.Create(FILE_NAME+".tif", rows, cols, 1, gdal.GDT_Float64)
geotransform = ([x0, cellSize, 0, y0, 0, -cellSize ])
outdata.SetGeoTransform(geotransform)
srs = osr.SpatialReference()
res = srs.ImportFromEPSG(4326)
if res != 0:
    logger.info('Could not import from EPSG')            
outdata.SetProjection(srs.ExportToWkt())
outdata.GetRasterBand(1).SetNoDataValue(np.nan)
outdata.GetRasterBand(1).WriteArray(result)
    
# Save to disk.
outdata.FlushCache()
outdata = None
