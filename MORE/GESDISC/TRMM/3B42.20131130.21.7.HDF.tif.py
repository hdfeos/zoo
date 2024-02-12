"""

This example code illustrates how to access, visualize, and convert a 
GESDISC TRMM 3B42 HDF4 Grid version 7 file to GeoTIFF in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python 3B42.20131130.21.7.HDF.tif.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2022-02-07
"""
import os
import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
# If GDAL installation fails, try conda-forge.
# $conda install -c conda-forge gdal
from osgeo import gdal, osr
from mpl_toolkits.basemap import Basemap
from pyhdf.SD import SD, SDC


FILE_NAME = '3B42.20131130.21.7.HDF'
hdf = SD(FILE_NAME, SDC.READ)
DATAFIELD_NAME = 'precipitation'
ds = hdf.select(DATAFIELD_NAME)
data = ds[:].astype(np.float64)

# Handle attributes.
attrs = ds.attributes(full=1)
ua=attrs["units"]
units = ua[0]

# Consider 0.0 to be the fill value.
# Must create a masked array where nan is involved.
data[data == 0.0] = np.nan
datam = np.ma.masked_where(np.isnan(data), data)
    
# The lat and lon should be calculated manually [1].
latitude = np.arange(-49.875, 49.875, 0.249375)
longitude = np.arange(-179.875, 179.876, 0.25)


# Draw an equidistant cylindrical projection using the high resolution
# coastline database.
m = Basemap(projection='cyl', resolution='h')
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 45))
m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
m.pcolormesh(longitude, latitude, datam.T, latlon=True)
cb = m.colorbar()
cb.set_label(units)
basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, DATAFIELD_NAME))
fig = plt.gcf()
pngfile = "{0}.tif.py.png".format(basename)
fig.savefig(pngfile)

# Create GeoTIFF.
[cols, rows] = data.T.shape
driver = gdal.GetDriverByName("GTiff")
outdata = driver.Create(FILE_NAME+".tif", rows, cols, 1, gdal.GDT_Float32)
x0 = -180.0
y0 = 50.0
geotransform = ([x0, 0.25, 0, y0, 0, -0.25 ])
outdata.SetGeoTransform(geotransform)
srs = osr.SpatialReference()
res = srs.ImportFromEPSG(4326)
if res != 0:
    logger.info('Could not import from EPSG')            
outdata.SetProjection(srs.ExportToWkt())
outdata.GetRasterBand(1).SetNoDataValue(np.nan)
outdata.GetRasterBand(1).WriteArray(data.T[:][::-1])
    
# Save to disk.
outdata.FlushCache()

# Use the following GDAL command to subset GeoTIFF.
# $gdalwarp -t_srs EPSG:4326 -te 68.0937058 12.47302 97.4240583 37.0848219  -ts 3285 3250 3B42.20131130.21.7.HDF.tif  subset.tif

# Run the following GDAL script to mask the subsetted GeoTIFF using Python.
# (We assume that miniconda is installed under ~/miniconda3.)
# $python ~/miniconda3/bin/gdal_calc.py -A subset.tif -B mask_region.tif --A_band=1 --B_band=1 --outfile=result.tif --calc="A*B

# Run the following GDAL command & Python script to superimpose images.
# 
# $gdal_translate -ot Float32 mask_region.tif mask_region_float.tif
# $python gdal_calc.py -A subset.tif --outfile=subset1.tif --calc="nan_to_num(A, nan=1.0)"
# $python ~/miniconda3/bin/gdal_calc.py -A mask_region_float.tif -B subset1.tif --A_band=1 --B_band=1 --outfile=result2.tif --calc="A*B"
#
# References
# [1] https://pmm.nasa.gov/sites/default/files/document_files/3B42_3B43_doc_V7.pdf
