"""
Copyright (C) 2020 The HDF Group

This example code illustrates how to merge and convert multiple GES DISC OMI L2 
HDF-EOS5 files to GeoTIFF files in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

  $python OMI-Aura_L2-OMAERUV_merge.SUB.he5.py

The HDF5 files must be in your current working directory.

Tested under: Python 3.7.3 :: Anaconda
Last updated: 2020-3-19
"""

import glob
import h5py
import numpy as np
from osgeo import gdal, osr

# Use $conda install -c conda-forge pyresample
from pyresample import kd_tree,geometry
from pyresample.plot import area_def2basemap
from pyresample import load_area, save_quicklook 
from pyresample.geometry import GridDefinition, SwathDefinition
from pyresample.kd_tree import resample_nearest

def get_date(fname):
    # Get date from "OMI-Aura_L2-OMAERUV_2019m0101t..." file name.
    # E.g.,  2019m0101
    return fname[20:29]

def is_new_date(new, old):
    dn = get_date(new)
    do = get_date(old)
    if dn == do:
        return False
    else:
        return True

def write_geotiff(lonm, latm, datam, FILE_NAME):
    # Define SwathDefinition.
    swathDef = SwathDefinition(lons=lonm, lats=latm)    

    # Define GridDefinition.
    cellSize = 1
    x0, xinc, y0, yinc = (-180, cellSize, 90, -cellSize)
    nx, ny = (360, 180)
    x = np.linspace(x0, x0 + xinc*nx, nx)
    y = np.linspace(y0, y0 + yinc*ny, ny)
    lon_g, lat_g = np.meshgrid(x, y)
    grid_def = GridDefinition(lons=lon_g, lats=lat_g)

    # Set radius_of_influence.
    ri = 50000
    result = resample_nearest(swathDef, datam, grid_def, 
                              radius_of_influence=ri, epsilon=0.5,
                              fill_value=np.nan)
    [cols, rows] = result.shape
    driver = gdal.GetDriverByName("GTiff")
    outdata = driver.Create(FILE_NAME+".tif", rows, cols, 1, gdal.GDT_Float32)
    
    geotransform = ([x0, 1, 0, y0, 0, -1 ])
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
    
OLD_FILE_NAME = None
i = 0
for file in sorted(glob.glob('OMI-Aura_L2-OMAERUV*.he5')):
    FILE_NAME =  file

    if OLD_FILE_NAME:
        new_date = is_new_date(FILE_NAME, OLD_FILE_NAME);
    else:
        new_date = False;
        
    DATAFIELD_NAME ='/HDFEOS/SWATHS/Aerosol NearUV Swath/Data Fields/FinalAerosolAbsOpticalDepth'
    with h5py.File(FILE_NAME, mode='r') as f:
        dset = f[DATAFIELD_NAME]
        data_t =dset[:].astype(np.float64)

        # Make 2D data by subsetting.
        data = data_t[:,:,0]
        # Retrieve any attributes that may be needed later.
        # String attributes actually come in as the bytes type and should
        # be decoded to UTF-8 (python3).
        scale = f[DATAFIELD_NAME].attrs['ScaleFactor']
        offset = f[DATAFIELD_NAME].attrs['Offset']
        missing_value = f[DATAFIELD_NAME].attrs['MissingValue']
        fill_value = f[DATAFIELD_NAME].attrs['_FillValue']
        title = f[DATAFIELD_NAME].attrs['Title'].decode()
        units = f[DATAFIELD_NAME].attrs['Units'].decode()

        # Retrieve the geolocation data.
        path = '/HDFEOS/SWATHS/Aerosol NearUV Swath/Geolocation Fields/'
        lat = f[path + 'Latitude'][:]
        lon = f[path + 'Longitude'][:]

        # Filter fill values.
        data[data == missing_value] = np.nan
        data[data == fill_value] = np.nan
        data = scale * (data - offset)
        datam = np.ma.masked_where(np.isnan(data), data)

        lat[lat == missing_value] = np.nan
        latm = np.ma.masked_where(np.isnan(lat), lat)
        lon[lon == missing_value] = np.nan
        lonm = np.ma.masked_where(np.isnan(lon), lon)

        if new_date:
            # Convert data into GeoTIFF using pyresample.
            write_geotiff(lon_m, lat_m, data_m, FILE_NAME)
            i = 0
        else:
            if i > 0:
                data_m = np.vstack([data_m, datam])
                lat_m = np.vstack([lat_m, latm])
                lon_m = np.vstack([lon_m, lonm])
                i = i+1
            
        if i == 0:
            data_m = datam
            lat_m = latm
            lon_m = lonm
            
    OLD_FILE_NAME =  FILE_NAME
