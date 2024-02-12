"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize an LP DAAC MYD09GQ
v6 HDF-EOS2 Sinusoidal Grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MYD09GQ.A2012246.h35v10.006.2015248145541.hdf.py

The HDF file and HDF-EOS2 dumper lat/lon outputs must be in your current 
working directory.

If you want to use netCDF APIs, the netcdf library must be compiled with 
HDF4 support.  

Tested under: Python 2.7.14 :: Anaconda custom (64-bit)
Last updated: 2018-05-04
"""
import os
import re
import pyproj

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from mpl_toolkits.basemap import Basemap



USE_NETCDF = False
USE_GDAL = False
def run(FILE_NAME):
    
    DATAFIELD_NAME = 'sur_refl_b01_1'

    if USE_NETCDF:

        from netCDF4 import Dataset

        # The scaling equation isn't what netcdf4 expects, so turn it off.
        nc = Dataset(FILE_NAME)
        ncvar = nc.variables[DATAFIELD_NAME]
        ncvar.set_auto_maskandscale(False)
        data = ncvar[:].astype(np.float64)

        # Get any needed attributes.
        scale_factor = ncvar.scale_factor
        add_offset = ncvar.add_offset
        _FillValue = ncvar._FillValue
        valid_range = ncvar.valid_range
        units = ncvar.units
        long_name = ncvar.long_name

        # Construct the grid.  The needed information is in a global attribute
        # called 'StructMetadata.0'.  Use regular expressions to tease out the
        # extents of the grid.
        gridmeta = getattr(nc, 'StructMetadata.0')
        ul_regex = re.compile(r'''UpperLeftPointMtrs=\(
                                  (?P<upper_left_x>[+-]?\d+\.\d+)
                                  ,
                                  (?P<upper_left_y>[+-]?\d+\.\d+)
                                  \)''', re.VERBOSE)
        match = ul_regex.search(gridmeta)
        x0 = np.float(match.group('upper_left_x'))
        y0 = np.float(match.group('upper_left_y'))

        lr_regex = re.compile(r'''LowerRightMtrs=\(
                                  (?P<lower_right_x>[+-]?\d+\.\d+)
                                  ,
                                  (?P<lower_right_y>[+-]?\d+\.\d+)
                                  \)''', re.VERBOSE)
        match = lr_regex.search(gridmeta)
        x1 = np.float(match.group('lower_right_x'))
        y1 = np.float(match.group('lower_right_y'))
        
        nx, ny = data.shape
        x = np.linspace(x0, x1, nx)
        y = np.linspace(y0, y1, ny)
        xv, yv = np.meshgrid(x, y)

        # In basemap, the sinusoidal projection is global, so we won't use it.
        # Instead we'll convert the grid back to lat/lons.
        sinu = pyproj.Proj("+proj=sinu +R=6371007.181 +nadgrids=@null +wktext")
        wgs84 = pyproj.Proj("+init=EPSG:4326") 
        lon, lat= pyproj.transform(sinu, wgs84, xv, yv)
    
    elif USE_GDAL:
        # Import GDAL library.
        import gdal

        GRID_NAME = 'MODIS_Grid_2D'
        gname = 'HDF4_EOS:EOS_GRID:"{0}":{1}:{2}'.format(FILE_NAME,
                                                         GRID_NAME,
                                                         DATAFIELD_NAME)
        gdset = gdal.Open(gname)
        data = gdset.ReadAsArray().astype(np.float64)
    
        # Get any needed attributes.
        meta = gdset.GetMetadata()
        scale_factor = np.float(meta['scale_factor'])
        add_offset = np.float(meta['add_offset'])
        _FillValue = np.float(meta['_FillValue'])
        valid_range = [np.float(x) for x in meta['valid_range'].split(', ')]
        units = meta['units']
        long_name = meta['long_name']
    
        # Construct the grid.
        x0, xinc, _, y0, _, yinc = gdset.GetGeoTransform()
        nx, ny = (gdset.RasterXSize, gdset.RasterYSize)
        x = np.linspace(x0, x0 + xinc*nx, nx)
        y = np.linspace(y0, y0 + yinc*ny, ny)
        xv, yv = np.meshgrid(x, y)


        # In basemap, the sinusoidal projection is global, so we won't use it.
        # Instead we'll convert the grid back to lat/lons.
        sinu = pyproj.Proj("+proj=sinu +R=6371007.181 +nadgrids=@null +wktext")
        wgs84 = pyproj.Proj("+init=EPSG:4326") 
        lon, lat= pyproj.transform(sinu, wgs84, xv, yv)

        del gdset
    else:
        # PyHDF
        from pyhdf.SD import SD, SDC
        hdf = SD(FILE_NAME, SDC.READ)

        # Read dataset.
        data2D = hdf.select(DATAFIELD_NAME)
        data = data2D[:,:].astype(np.double)

        # Read geolocation dataset from HDF-EOS2 dumper output.
        GEO_FILE_NAME = 'lat_MYD09GQ.A2012246.h35v10.006.2015248145541.output'
        lat = np.genfromtxt(GEO_FILE_NAME, delimiter=',', usecols=[0])
        lat = lat.reshape(data.shape)

        GEO_FILE_NAME = 'lon_MYD09GQ.A2012246.h35v10.006.2015248145541.output'
        lon = np.genfromtxt(GEO_FILE_NAME, delimiter=',', usecols=[0])
        lon = lon.reshape(data.shape)
        
        # Read attributes.
        attrs = data2D.attributes(full=1)
        lna=attrs["long_name"]
        long_name = lna[0]
        vra=attrs["valid_range"]
        valid_range = vra[0]
        fva=attrs["_FillValue"]
        _FillValue = fva[0]
        sfa=attrs["scale_factor"]
        scale_factor = sfa[0]        
        ua=attrs["units"]
        units = ua[0]
        aoa=attrs["add_offset"]
        add_offset = aoa[0]

    # Apply the attributes to the data.
    invalid = np.logical_or(data < valid_range[0], data > valid_range[1])
    invalid = np.logical_or(invalid, data == _FillValue)
    data[invalid] = np.nan
    data = (data - add_offset) / scale_factor
    data = np.ma.masked_array(data, np.isnan(data))
    
    # There is a wrap-around issue to deal with, as some of the grid extends
    # eastward over the international dateline.  Adjust the longitude to avoid
    # a smearing effect.
    lon[lon < 0] += 360

    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=np.min(lat), urcrnrlat = np.max(lat),
                llcrnrlon=np.min(lon), urcrnrlon = np.max(lon))                
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(np.floor(np.min(lat)), np.ceil(np.max(lat)), 5),
                    labels=[1, 0, 0, 0])
    m.drawmeridians(np.arange(np.floor(np.min(lon)), np.ceil(np.max(lon)), 5),
                    labels=[0, 0, 0, 1])
    
    # Subset data if you don't see any plot due to limited memory.
    # m.pcolormesh(lon, lat, data, latlon=True)
    m.pcolormesh(lon[::2,::2], lat[::2,::2], data[::2,::2], latlon=True)

    cb = m.colorbar()
    cb.set_label(units)

    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, long_name))
    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)


if __name__ == "__main__":
    hdffile = 'MYD09GQ.A2012246.h35v10.006.2015248145541.hdf'
    run(hdffile)
    

