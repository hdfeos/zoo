"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize a LP DAAC MEaSURES 
VIP01 version 4 HDF-EOS2 grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python VIP01.A2010001.004.2016177161542.hdf.py

The HDF file must either be in your current working directory or in a directory
specified by the environment variable HDFEOS_ZOO_DIR.

In order for the netCDF code path to work, the netcdf library must be compiled
with HDF4 support. 

Tested under: Python 2.7.14 :: Anaconda custom (64-bit)
Last updated: 2018-05-07
"""

import os
import re


import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import pyproj
import numpy as np

# You can use netCDF, GDAL, or pyhdf module.
# Make either one True if you'd like to use netCDF or GDAL.
USE_NETCDF = False
USE_GDAL = False

def run(FILE_NAME):
    
    DATAFIELD_NAME = 'CMG 0.05 Deg Daily NDVI'

    if USE_GDAL:
        # GDAL
        import gdal

        GRID_NAME = 'VIP_CMG_GRID'
        gname = 'HDF4_EOS:EOS_GRID:"{0}":{1}:{2}'.format(FILE_NAME,
                                                         GRID_NAME,
                                                         DATAFIELD_NAME)

        # Scale down the data by a factor of 6 so that low-memory machines
        # can handle it.
        gdset = gdal.Open(gname)
        data = gdset.ReadAsArray().astype(np.float64)[::6, ::6]
    
        # Get any needed attributes.
        meta = gdset.GetMetadata()
        scale = np.float(meta['scale_factor'])
        fillvalue = np.float(meta['_FillValue'])
        valid_range = [np.float(x) for x in meta['valid_range'].split(', ')]
        units = meta['units']
        long_name = meta['long_name']
    
        # Construct the grid.
        x0, xinc, _, y0, _, yinc = gdset.GetGeoTransform()
        ny, nx = (gdset.RasterYSize / 6, gdset.RasterXSize / 6)
        x = np.linspace(x0, x0 + xinc*6*nx, nx)
        y = np.linspace(y0, y0 + yinc*6*ny, ny)
        lon, lat = np.meshgrid(x, y)

        del gdset

    else:
        if USE_NETCDF:

            from netCDF4 import Dataset

            # The scaling equation isn't what netcdf4 expects, so turn it off.
            # Scale down the data by a factor of 6 so that low-memory machines
            # can handle it.
            nc = Dataset(FILE_NAME)
            ncvar = nc.variables[DATAFIELD_NAME]
            ncvar.set_auto_maskandscale(False)

            # Scale down the data by a factor of 6 so that low-memory machines
            # can handle it.
            data = ncvar[::6, ::6].astype(np.float64)

            # Get any needed attributes.  
            scale = ncvar.scale_factor
            fillvalue = ncvar._FillValue
            
            # The valid_range attribute is a string, not float array.
            valid_range = [np.float64(x) for x in ncvar.valid_range.split(', ')]
            units = ncvar.units
            long_name = ncvar.long_name
            gridmeta = getattr(nc, 'StructMetadata.0')

        else:
            from pyhdf.SD import SD, SDC
            hdf = SD(FILE_NAME, SDC.READ)
            # Read dataset.
            data2D = hdf.select(DATAFIELD_NAME)
            data = data2D[:,:].astype(np.double)

            # Scale down the data by a factor of 6 so that low-memory machines
            # can handle it.
            data = data[::6, ::6]
            # print(data[:, 1028])
        
            # Read attributes.
            attrs = data2D.attributes(full=1)
            lna=attrs["long_name"]
            long_name = lna[0]
            vra=attrs["valid_range"]
            valid_range_s = vra[0]

            # The valid_range attribute is a string, not float array.
            valid_range = [np.float64(x) for x in valid_range_s.split(', ')]
            
            fva=attrs["_FillValue"]
            fillvalue = fva[0]
            sfa=attrs["scale_factor"]
            scale = sfa[0]
            ua=attrs["units"]
            units = ua[0]
            fattrs = hdf.attributes(full=1)
            ga = fattrs["StructMetadata.0"]
            gridmeta = ga[0]
            
        # Construct the grid.  The needed information is in a global attribute
        # called 'StructMetadata.0'.  Use regular expressions to tease out the
        # extents of the grid.  In addition, the grid is in packed decimal
        # degrees, so we need to normalize to degrees.

        ul_regex = re.compile(r'''UpperLeftPointMtrs=\(
                                  (?P<upper_left_x>[+-]?\d+\.\d+)
                                  ,
                                  (?P<upper_left_y>[+-]?\d+\.\d+)
                                  \)''', re.VERBOSE)
        match = ul_regex.search(gridmeta)
        x0 = np.float(match.group('upper_left_x')) / 1e6
        y0 = np.float(match.group('upper_left_y')) / 1e6

        lr_regex = re.compile(r'''LowerRightMtrs=\(
                                  (?P<lower_right_x>[+-]?\d+\.\d+)
                                  ,
                                  (?P<lower_right_y>[+-]?\d+\.\d+)
                                  \)''', re.VERBOSE)
        match = lr_regex.search(gridmeta)
        x1 = np.float(match.group('lower_right_x')) / 1e6
        y1 = np.float(match.group('lower_right_y')) / 1e6
        
        ny, nx = data.shape
        x = np.linspace(x0, x1, nx)
        y = np.linspace(y0, y1, ny)
        lon, lat = np.meshgrid(x, y)

    # Handle fill value
    invalid = data == fillvalue
    invalid = np.logical_or(invalid, data < valid_range[0])
    invalid = np.logical_or(invalid, data > valid_range[1])
    data[invalid] = np.nan    
    data = data / scale
    data = np.ma.masked_array(data, np.isnan(data))
    
    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon = 180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90, 91, 30), labels=[1, 0, 0, 0])
    m.drawmeridians(np.arange(-180, 181, 45), labels=[0, 0, 0, 1])

    m.pcolormesh(lon, lat, data, latlon=True)
    cb = m.colorbar()
    cb.set_label(units, fontsize=6)

    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, long_name))
    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)


if __name__ == "__main__":

    # If a certain environment variable is set, look there for the input
    # file, otherwise look in the current directory.
    hdffile = 'VIP01.A2010001.004.2016177161542.hdf'
    try:
        hdffile = os.path.join(os.environ['HDFEOS_ZOO_DIR'], hdffile)
    except KeyError:
        pass

    run(hdffile)
