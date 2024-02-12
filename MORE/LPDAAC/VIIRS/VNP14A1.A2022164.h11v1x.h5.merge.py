"""

This example code illustrates how to access and visualize VNP14A1
multiple HDF-EOS5 Sinusoidal projection Grid files in Python.
This code also creates a GeoTIFF file from the merged dataset.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage: save this script and run

    $python VNP14A1.A2022164.h11v1x.h5.merge.py

The HDF files must be in your current working directory.

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2022-06-16
"""
import os
import re
import h5py
import glob
import pyproj

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from mpl_toolkits.basemap import Basemap

# For GeoTIFF generation
from osgeo import gdal, osr
from pyresample import kd_tree,geometry
from pyresample.plot import area_def2basemap
from pyresample import load_area, save_quicklook 
from pyresample.geometry import GridDefinition, SwathDefinition
from pyresample.kd_tree import resample_nearest

# This dataset has mostly fill value.
# name = '/HDFEOS/GRIDS/VNP14A1_Grid/Data Fields/MaxFRP'

# This dataset shows land/sea clearly.
name = '/HDFEOS/GRIDS/VNP14A1_Grid/Data Fields/FireMask'
i = 0

for fname in list(sorted(glob.glob('VNP14A1.A2022164.h11v1*.h5'))):
    with h5py.File(fname, mode='r') as f:
        data = f[name][:]
        # This is for MaxFRP.
        # _FillValue = f[name].attrs['_FillValue']
        # scale_factor = f[name].attrs['scale_factor']
        # dataf = scale_factor * data
        # dataf[data == _FillValue] = np.nan
        # dataf = np.ma.masked_where(np.isnan(dataf), dataf)

        # This is for FireMask
        dataf = data.astype(np.float64)
        
        # Read metadata. 
        gridmeta = f['/HDFEOS INFORMATION/StructMetadata.0'][()]
        s = gridmeta.decode('UTF-8')
        
        # Construct the grid.  The needed information is in a string dataset
        # called 'StructMetadata.0'.  Use regular expressions to retrieve
        # extents of the grid. 
        ul_regex = re.compile(r'''UpperLeftPointMtrs=\((?P<upper_left_x>[+-]?\d+\.\d+),(?P<upper_left_y>[+-]?\d+\.\d+)\)''', re.VERBOSE)
        match = ul_regex.search(s)
        x0 = float(match.group('upper_left_x')) 
        y0 = float(match.group('upper_left_y')) 
        lr_regex = re.compile(r'''LowerRightMtrs=\(
        (?P<lower_right_x>[+-]?\d+\.\d+)
        ,
        (?P<lower_right_y>[+-]?\d+\.\d+)
        \)''', re.VERBOSE)
        match = lr_regex.search(s)
        x1 = float(match.group('lower_right_x'))
        y1 = float(match.group('lower_right_y'))
        ny, nx = data.shape
        x = np.linspace(x0, x1, nx, endpoint=False)
        y = np.linspace(y0, y1, ny, endpoint=False)
        xv, yv = np.meshgrid(x, y)
        sinu = pyproj.Proj("+proj=sinu +R=6371007.181 +nadgrids=@null +wktext")
        wgs84 = pyproj.Proj("+init=EPSG:4326") 
        longitude, latitude= pyproj.transform(sinu, wgs84, xv, yv)

        if i == 0 :
            FILE_NAME = fname

            # This is for MaxFRP.
            # units = f[name].attrs['units']
            # units = units.decode('ascii', 'replace')
            long_name = f[name].attrs['long_name']
            long_name = long_name.decode('ascii', 'replace')
            data_m = dataf
            latitude_m = latitude
            longitude_m = longitude
        else:
            data_m = np.vstack([data_m, dataf])
            latitude_m = np.vstack([latitude_m, latitude])
            longitude_m = np.vstack([longitude_m, longitude])
        i = i + 1

xmin = -180.0
xmax = 180.0
ymin = -90.0
ymax = 90.0
xtick = 60
ytick = 30

# Use the following for zoomed image.
# xmin = np.min(longitude_m)
# xmax = np.max(longitude_m)
# ymin = np.min(latitude_m)
# ymax = np.max(latitude_m)
# xtick = 10
# ytick = 5
m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=ymin, urcrnrlat=ymax,
            llcrnrlon=xmin, urcrnrlon=xmax)
m.drawcoastlines(linewidth=0.5)
m.drawmeridians(np.arange(np.floor(xmin), np.ceil(xmax), xtick),
                labels=[0, 0, 0, 1])
m.drawparallels(np.arange(np.floor(ymin), np.ceil(ymax), ytick),
                labels=[1, 0, 0, 0])
sc = m.scatter(longitude_m, latitude_m, c=data_m, s=0.1, cmap=plt.cm.jet,
                edgecolors=None, linewidth=0)
cb = m.colorbar()

# This is for MaxFRP.
# cb.set_label(units)


# Put title using the first file.
basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, name))
fig = plt.gcf()

# Save image.
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)


# Convert data into EPSG:4326 GeoTIFF using pyresample.
# Define SwathDefinition.
swathDef = SwathDefinition(lons=longitude_m, lats=latitude_m)    

# Define GridDefinition.
# 0.01 degree is about 1.11km.
cellSize = 0.01

# cellSize = 0.001

# cellSize = 0.0001
min_lon = np.min(longitude_m)
max_lon = np.max(longitude_m)
min_lat = np.min(latitude_m)
max_lat = np.max(latitude_m)
x0, xinc, y0, yinc = (min_lon, cellSize, max_lat, -cellSize)
nx = int(np.floor((max_lon - min_lon) / cellSize))
ny = int(np.floor((max_lat - min_lat) / cellSize))
x = np.linspace(x0, x0 + xinc*nx, nx)
y = np.linspace(y0, y0 + yinc*ny, ny)
lon_g, lat_g = np.meshgrid(x, y)
grid_def = GridDefinition(lons=lon_g, lats=lat_g)

# Set radius_of_influence in meters.
# Use this for 0.01 cellSize.
ri = 1000

# Use this for 0.001 cellSize.
# ri = 100

# Use this for 0.0001 cellSize.
# ri = 10

# To check the effect of cellSize and ri, print out min/max values of
# the original data and resampled data.
# print(np.nanmin(data_m))
# print(np.nanmax(data_m))
result = resample_nearest(swathDef, data_m, grid_def, 
                          radius_of_influence=ri, epsilon=0.5,
                          fill_value=np.nan)
# print(np.nanmin(result))
# print(np.nanmax(result))
[cols, rows] = result.shape
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

