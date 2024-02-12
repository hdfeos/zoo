"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize an LP_DAAC MYD11C2
grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python MYD11C2_LST_Night_CMG.py

The HDF file must either be in your current working directory or in a directory
specified by the environment variable HDFEOS_ZOO_DIR.

In order for the netCDF code path to work, the netcdf library must be compiled
with HDF4 support.  Please see the README for details.
"""

import os
import re

import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import mpl_toolkits.basemap.pyproj as pyproj
import numpy as np

USE_GDAL = False
USE_NETCDF = False

def run(FILE_NAME):
    
    DATAFIELD_NAME = 'LST_Night_CMG'

    if USE_GDAL:
        # GDAL
        import gdal

        GRID_NAME = 'MODIS_8DAY_0.05DEG_CMG_LST'
        gname = 'HDF4_EOS:EOS_GRID:"{0}":{1}:{2}'.format(FILE_NAME,
                                                         GRID_NAME,
                                                         DATAFIELD_NAME)
        gdset = gdal.Open(gname)
        # data = gdset.ReadAsArray().astype(np.float64)[::4, ::4]
        data = gdset.ReadAsArray().astype(np.float64)[:,:]
        # Get any needed attributes.
        meta = gdset.GetMetadata()
        scale_factor = np.float(meta['scale_factor'])
        add_offset = np.float(meta['add_offset'])
        _FillValue = np.float(meta['_FillValue'])
        valid_range = [np.float(x) for x in meta['valid_range'].split(', ')]
        units = meta['units']
        long_name = meta['long_name']
    
        # Construct the grid.  Subset by a factor of 4.
        x0, xinc, _, y0, _, yinc = gdset.GetGeoTransform()
        # nx, ny = (gdset.RasterXSize / 4, gdset.RasterYSize / 4)
        nx, ny = (gdset.RasterXSize, gdset.RasterYSize)
        # x = np.linspace(x0, x0 + xinc*4*nx, nx)
        # y = np.linspace(y0, y0 + yinc*4*ny, ny)
        x = np.linspace(x0, x0 + xinc*nx, nx)
        y = np.linspace(y0, y0 + yinc*ny, ny)
        lon, lat = np.meshgrid(x, y)

        del gdset

    
    else:
        if USE_NETCDF:

            from netCDF4 import Dataset

            # The scaling equation isn't what netcdf4 expects, so turn it off.
            nc = Dataset(FILE_NAME)
            ncvar = nc.variables[DATAFIELD_NAME]
            ncvar.set_auto_maskandscale(False)
            data = ncvar[::4, ::4].astype(np.float64)

            # Get any needed attributes.
            scale_factor = ncvar.scale_factor
            add_offset = ncvar.add_offset
            _FillValue = ncvar._FillValue
            valid_range = ncvar.valid_range
            units = ncvar.units
            long_name = ncvar.long_name
            gridmeta = getattr(nc, 'StructMetadata.0')


        else:
            from pyhdf.SD import SD, SDC
            hdf = SD(FILE_NAME, SDC.READ)

            # Read dataset.
            data2D = hdf.select(DATAFIELD_NAME)
            data = data2D[:,:].astype(np.double)

        
            # Read attributes.
            attrs = data2D.attributes(full=1)
            lna=attrs["long_name"]
            long_name = lna[0]
            vra=attrs["valid_range"]
            valid_range = vra[0]
            aoa=attrs["add_offset"]
            add_offset = aoa[0]
            fva=attrs["_FillValue"]
            _FillValue = fva[0]
            sfa=attrs["scale_factor"]
            scale_factor = sfa[0]        
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


    # Apply the attributes to the data.
    invalid = np.logical_or(data < valid_range[0], data > valid_range[1])
    invalid = np.logical_or(invalid, data ==_FillValue)
    data[invalid] = np.nan
    data = (data - add_offset) * scale_factor
    data = np.ma.masked_array(data, np.isnan(data))
    
    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon = 180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90, 91, 30), labels=[1, 0, 0, 0])
    m.drawmeridians(np.arange(-180, 181, 45), labels=[0, 0, 0, 1])

    m.pcolormesh(lon, lat, data, latlon=True)
    cb = m.colorbar()
    cb.set_label(units)

    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, long_name))
    fig = plt.gcf()
    # plt.show()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)


if __name__ == "__main__":

    # If a certain environment variable is set, look there for the input
    # file, otherwise look in the current directory.
    hdffile = 'MYD11C2.A2006337.004.2006348062459.hdf'
    try:
        hdffile = os.path.join(os.environ['HDFEOS_ZOO_DIR'], hdffile)
    except KeyError:
        pass

    run(hdffile)
    

