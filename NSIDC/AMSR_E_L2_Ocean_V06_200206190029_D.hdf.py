"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize an NSIDC AMSR-E
Ocean HDF-EOS2 Swath data file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python AMSR_E_L2_Ocean_V06_200206190029_D.hdf.py

The HDF file must be in your current working directory.
"""

import os

import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

USE_NETCDF4 = False

FILE_NAME = 'AMSR_E_L2_Ocean_V06_200206190029_D.hdf'

# Identify the data field.
DATAFIELD_NAME = 'High_res_cloud'

if USE_NETCDF4:
    from netCDF4 import Dataset
    nc = Dataset(FILE_NAME)
    data = nc.variables[DATAFIELD_NAME][:].astype(np.float64)
    latitude = nc.variables['Latitude'][:]
    longitude = nc.variables['Longitude'][:]
    scale_factor = nc.variables[DATAFIELD_NAME].Scale
else:
    from pyhdf.SD import SD, SDC
    hdf = SD(FILE_NAME, SDC.READ)

    # Read dataset.
    data2D = hdf.select(DATAFIELD_NAME)
    data = data2D[:,:].astype(np.float64)

    # Read geolocation dataset.
    lat = hdf.select('Latitude')
    latitude = lat[:,:]
    lon = hdf.select('Longitude')
    longitude = lon[:,:]

    # Retrieve attributes.
    attrs = data2D.attributes(full=1)
    sfa=attrs["Scale"]
    scale_factor = sfa[0]        

# There is a wrap-around effect to deal with, as some of the swath extends
# eastward over the international dateline.  Adjust the longitude to avoid
# the swath being smeared.
longitude[longitude < -170] += 360

# Apply the fill value and scaling equation.
data[data == -9990] = np.nan
data = data * scale_factor
data = np.ma.masked_array(data, np.isnan(data))

units = "mm"
long_name = DATAFIELD_NAME

# Draw a polar stereographic projection using the low resolution coastline
# database.
m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=-90, urcrnrlat=90,
            llcrnrlon=-170, urcrnrlon=190)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 45), labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(-180,181,45), labels=[0, 0, 0, 1])
m.pcolormesh(longitude, latitude, data, latlon=True)

cb = m.colorbar()
cb.set_label(units)

basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, long_name))
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)

