"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize a LaRC CERES ES4 TRMM
Edition2 HDF-EOS2 Grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python CER_ES4_TRMM-PFM_Edition2_019018.199808.hdf.py

The HDF file must either be in your current working directory
or in a directory specified by the environment variable HDFEOS_ZOO_DIR.

In order for the netCDF code path to work, the netcdf library must be compiled
with HDF4 support. 

Tested under: Python 2.7.15 :: Anaconda custom (64-bit)
Last updated: 2018-06-29
"""

import os

import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

USE_NETCDF4 = False

def run(FILE_NAME):
    # Identify the data field.
    DATAFIELD_NAME = 'Longwave flux'

    if USE_NETCDF4:
        from netCDF4 import Dataset
        nc = Dataset(FILE_NAME)
        var = nc.variables[DATAFIELD_NAME]
        data = var[:].astype(np.float64)
        latitude = nc.variables['Colatitude'][:]
        longitude = nc.variables['Longitude'][:]
        units = var.units
        long_name = var.long_name
        fillvalue = var._FillValue
    else:
        from pyhdf.SD import SD, SDC
        hdf = SD(FILE_NAME, SDC.READ)
        # print(hdf.datasets())
        # Read dataset.
        data2D = hdf.select(DATAFIELD_NAME)
        data = data2D[:,:]
        
        # Read geolocation datasets.
        lat = hdf.select('Colatitude')
        latitude = lat[:]
        lon = hdf.select('Longitude')
        longitude = lon[:]

        # Read attributes.
        attrs = data2D.attributes(full=1)
        la=attrs["long_name"]
        long_name = la[0]
        ua=attrs["units"]
        units = ua[0]
        fva=attrs["_FillValue"]
        fillvalue = fva[0]

    # Set fillvalue and units.
    data[data == fillvalue] = np.nan
    datam = np.ma.masked_array(data, mask=np.isnan(data))

    
    # Adjust lat/lon values.
    latitude = 90 - latitude
    longitude[longitude>180]=longitude[longitude>180]-360;
    
    # The data is global, so render in a global projection.
    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon=180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90.,90,45))
    m.drawmeridians(np.arange(-180.,180,45), labels=[True,False,False,True])
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
    hdf_file = 'CER_ES4_TRMM-PFM_Edition2_019018.199808.hdf'
    try:
        fname = os.path.join(os.environ['HDFEOS_ZOO_DIR'], hdf_file)
    except KeyError:
        fname = hdf_file

    run(fname)

# References
# [1] http://ceres.larc.nasa.gov/documents/collect_guide/pdf/ES4_CG_R1V1.pdf

