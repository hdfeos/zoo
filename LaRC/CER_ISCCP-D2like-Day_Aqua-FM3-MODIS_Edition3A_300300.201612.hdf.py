"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize a LaRC CERES file in
file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python CER_ISCCP-D2like-Day_Aqua-FM3-MODIS_Edition3A_300300.201612.hdf.py

The HDF4 file must either be in your current working directory
or in a directory specified by the environment variable HDFEOS_ZOO_DIR.

Tested under: Python 2.7.15 :: Anaconda custom (64-bit)
Last updated: 2018-08-07
"""

import os

import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

USE_NETCDF4 = False

def run(FILE_NAME):

    # Identify the data field.
    DATAFIELD_NAME = 'Liquid Log Optical Depth - Altocumulus - Monthly Mean'

    if USE_NETCDF4:    
    
        from netCDF4 import Dataset
        nc = Dataset(FILE_NAME)
        # Subset the data to match the size of the swath geolocation fields.
        # Turn off autoscaling, we'll handle that ourselves due to presence of
        # a valid range.
        var = nc.variables[DATAFIELD_NAME]
        data = var[0,:,:].astype(np.float64)
    
        # Read the attributes.
        fillvalue = var._FillValue
        units = var.units
        long_name = var.long_name
        
    else:
        from pyhdf.SD import SD, SDC
        hdf = SD(FILE_NAME, SDC.READ)
        # Uncomment the following line to see available datasets in file.
        # print(hdf.datasets())
        
        # Read dataset.
        data3D = hdf.select(DATAFIELD_NAME)
        data = data3D[0,:,:].astype(np.float64)

        # Read attributes.
        attrs = data3D.attributes(full=1)
        fva = attrs["_FillValue"]
        fillvalue = fva[0]
        ua = attrs["units"]
        units = ua[0]
        ln = attrs["long_name"]
        long_name = ln[0]        

    # Handle fill value.
    data[data == fillvalue] = np.nan
    datam = np.ma.masked_array(data, mask=np.isnan(data))

    # The normal grid information is not present.  We have to generate the geo-
    # location data.
    ysize, xsize = data.shape
    xinc = 360.0 / xsize
    yinc = 180.0 / ysize
    x0, x1 = (-180, 180)
    y0, y1 = (-90, 90)
    lon = np.linspace(x0 + xinc/2, x1 - xinc/2, xsize)
    lat = np.linspace(y0 + yinc/2, y1 - yinc/2, ysize)

    # Flip the latitude to run from 90 to -90.
    lat = lat[::-1]
    longitude, latitude = np.meshgrid(lon, lat)

    # Read geolocation datasets.
    lat = hdf.select('Colatitude - Monthly Mean')
    latitude = lat[0,:]

    lon = hdf.select('Longitude - Monthly Mean')
    longitude = lon[0,:]
    
    # Adjust lat/lon values.
    latitude = 90 - latitude
    longitude[longitude>180]=longitude[longitude>180]-360;

    
    # The data is global, so render in a global projection.
    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon=180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90.,90,45))
    m.drawmeridians(np.arange(-180.,180,45))
    m.pcolormesh(longitude, latitude, datam, latlon=True)
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
    hdffile = 'CER_ISCCP-D2like-Day_Aqua-FM3-MODIS_Edition3A_300300.201612.hdf'
    try:
        fname = os.path.join(os.environ['HDFEOS_ZOO_DIR'], hdffile)
    except KeyError:
        fname = hdffile

    run(fname)

