"""

This example code illustrates how to access and visualize VNP21 NRT 
multiple netCDF-4/HDF5 Swath files in Python. This code also creates a GeoTIFF
file from the merged dataset.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage: save this script and run

    $python VNP21_NRT_merge.py

The HDF files must be in your current working directory.

Tested under: Python 3.7.7 :: Anaconda custom (x86_64)
Last updated: 2021-01-13
"""
import os
import h5py
import glob                                                                 
import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap

# For GeoTIFF generation
from osgeo import gdal, osr
from pyresample import kd_tree,geometry
from pyresample.plot import area_def2basemap
from pyresample import load_area, save_quicklook 
from pyresample.geometry import GridDefinition, SwathDefinition
from pyresample.kd_tree import resample_nearest


name = 'VIIRS_Swath_LSTE/Data Fields/LST'
i = 0

for fname in list(glob.glob('VNP21_NRT.*.nc')):
    with h5py.File(fname, mode='r') as f:
        data = f[name][:]
        _FillValue = f[name].attrs['_FillValue']
        add_offset = f[name].attrs['add_offset']
        scale_factor = f[name].attrs['scale_factor']
        valid_range = f[name].attrs['valid_range']
        valid_min = valid_range[0]
        valid_max = valid_range[1]
        invalid = np.logical_or(data > valid_max,
                                data < valid_min)
        invalid = np.logical_or(invalid, data == _FillValue)
        dataf = scale_factor * data + add_offset
        dataf[invalid] = np.nan
        dataf = np.ma.masked_where(np.isnan(dataf), dataf)
        latitude = f['/VIIRS_Swath_LSTE/Geolocation Fields/latitude'][:]
        longitude = f['/VIIRS_Swath_LSTE/Geolocation Fields/longitude'][:]

        if i == 0 :
            units = f[name].attrs['units']
            units = units.decode('ascii', 'replace')
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

m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon=180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 45))
m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
sc = m.scatter(longitude_m, latitude_m, c=data_m, s=0.1, cmap=plt.cm.jet,
                edgecolors=None, linewidth=0)
cb = m.colorbar()
cb.set_label(units)


# Put title using the first file.
FILE_NAME = 'VNP21_NRT.A2021005.0000.001.nc'
basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, name))
fig = plt.gcf()

# Save image.
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)


# Convert data into GeoTIFF using pyresample.
# Define SwathDefinition.
swathDef = SwathDefinition(lons=longitude_m, lats=latitude_m)    

# Define GridDefinition.
# 0.01 degree is about 1.11km, which is close enough to 750m native resolution.
cellSize = 0.01 
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
ri = 500
result = resample_nearest(swathDef, data_m, grid_def, 
                          radius_of_influence=ri, epsilon=0.5,
                          fill_value=np.nan)
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
