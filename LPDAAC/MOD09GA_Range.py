"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize an LP_DAAC MOD09GA
grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python MOD09GA_Range.py

The HDF file must either be in your current working directory or in a directory
specified by the environment variable HDFEOS_ZOO_DIR.
"""

import os
import re


import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import mpl_toolkits.basemap.pyproj as pyproj
import numpy as np

USE_GDAL = False

def run(FILE_NAME):
    
    # Identify the data field.
    DATAFIELD_NAME = 'Range_1'

    if  USE_GDAL:    
        import gdal
        GRID_NAME = 'MODIS_Grid_1km_2D'
        gname = 'HDF4_EOS:EOS_GRID:"{0}":{1}:{2}'.format(FILE_NAME,
                                                         GRID_NAME,
                                                         DATAFIELD_NAME)
        gdset = gdal.Open(gname)
        data = gdset.ReadAsArray().astype(np.float64)


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

        # Read the attributes.
        meta = gdset.GetMetadata()
        long_name = meta['long_name']        
        units = meta['units']
        _FillValue = np.float(meta['_FillValue'])
        scale_factor = np.float(meta['scale_factor'])
        valid_range = [np.float(x) for x in meta['valid_range'].split(', ')] 


        del gdset
    else:
        from pyhdf.SD import SD, SDC
        hdf = SD(FILE_NAME, SDC.READ)

        # Read dataset.
        data2D = hdf.select(DATAFIELD_NAME)
        data = data2D[:,:].astype(np.double)

        # Read geolocation dataset from HDF-EOS2 dumper output.
        GEO_FILE_NAME = 'lat_MOD09GA.A2007268.h10v08.005.2007272184810_MODIS_Grid_1km_2D.output'
        GEO_FILE_NAME = os.path.join(os.environ['HDFEOS_ZOO_DIR'], 
                                     GEO_FILE_NAME)
        lat = np.genfromtxt(GEO_FILE_NAME, delimiter=',', usecols=[0])
        lat = lat.reshape(data.shape)

        GEO_FILE_NAME = 'lon_MOD09GA.A2007268.h10v08.005.2007272184810_MODIS_Grid_1km_2D.output'
        GEO_FILE_NAME = os.path.join(os.environ['HDFEOS_ZOO_DIR'], 
                                      GEO_FILE_NAME)
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
        
    invalid = np.logical_or(data > valid_range[1],
                            data < valid_range[0])
    invalid = np.logical_or(invalid, data == _FillValue)
    data[invalid] = np.nan
    data = data / scale_factor 
    data = np.ma.masked_array(data, np.isnan(data))


    m = Basemap(projection='cyl', resolution='h',
                llcrnrlat=-2.5, urcrnrlat = 12.5,
                llcrnrlon=-82.5, urcrnrlon = -67.5)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(0, 15, 5), labels=[1, 0, 0, 0])
    m.drawmeridians(np.arange(-80, -65, 5), labels=[0, 0, 0, 1])
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
    hdffile = 'MOD09GA.A2007268.h10v08.005.2007272184810.hdf'
    try:
        hdffile = os.path.join(os.environ['HDFEOS_ZOO_DIR'], hdffile)
    except KeyError:
        pass

    run(hdffile)
    
