"""
Copyright (C) 2014-2018 The HDF Group
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize a NSIDC Level-2
MODIS HDF-EOS2 Swath data file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MOD10_L2.A2000065.0040.006.2016058071909.hdf.py

The HDF file must be in your current working directory.

The netcdf library must be compiled with HDF4 support in order for this example
code to work. 

Tested under: Python 2.7.15 :: Anaconda custom (64-bit)
Last updated: 2018-12-18
"""

import os

import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
from matplotlib import colors
import numpy as np

USE_NETCDF4 = False

def run(FILE_NAME):

    # Identify the data field.
    DATAFIELD_NAME = 'NDSI_Snow_Cover'
    
    if USE_NETCDF4:
        from netCDF4 import Dataset
        nc = Dataset(FILE_NAME)
        # Subset the data to match the size of the swath geolocation fields.
        rows = slice(5, 4060, 10)
        cols = slice(5, 2708, 10)
        data = nc.variables[DATAFIELD_NAME][rows, cols]
        latitude = nc.variables['Latitude'][:]
        longitude = nc.variables['Longitude'][:]
    else:
        from pyhdf.SD import SD, SDC
        hdf = SD(FILE_NAME, SDC.READ)

        # Read dataset.
        data2D = hdf.select(DATAFIELD_NAME)
        # Use the following for low resolution.
        # This is good for low memory machine.
        rows = slice(5, 4060, 10)
        cols = slice(5, 2708, 10)
        data = data2D[rows, cols]
        latitude = hdf.select('Latitude')[:]
        longitude = hdf.select('Longitude')[:]
        
        # Read dataset attribute.
        attrs = data2D.attributes(full=1)
        lna = attrs["long_name"]
        long_name= lna[0]

        # Use the following for high resolution.
        # This may not work for low memory machine.
#        data = data2D[:,:]
        # Read geolocation dataset from HDF-EOS2 dumper output.
#        GEO_FILE_NAME = 'lat_MOD10_L2.A2000065.0040.005.2008235221207.output'
#        lat = np.genfromtxt(GEO_FILE_NAME, delimiter=',', usecols=[0])
#        latitude = lat.reshape(data.shape)
        
#        GEO_FILE_NAME = 'lon_MOD10_L2.A2000065.0040.005.2008235221207.output'
#        lon = np.genfromtxt(GEO_FILE_NAME, delimiter=',', usecols=[0])
#        longitude = lon.reshape(data.shape)

    # Draw a polar stereographic projection using the low resolution coastline
    # database.
    m = Basemap(projection='npstere', resolution='l',
                boundinglat=64, lon_0 = 0)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(60.,81,10.))
    m.drawmeridians(np.arange(-180.,181.,30.), labels=[True,False,False,True])
    #  Key: = 0-100=ndsi snow, 200=missing data, 201=no decision, 211=night, 237=inland water, 239=ocean, 250=cloud, 254=detector saturated, 255=fill
    # Use a discretized colormap since we have only two levels.
    cmap = colors.ListedColormap(['purple', 'blue'])
    # Define the bins and normalize for discrete colorbar.
    bounds = np.array([211.0,237.0,239.0])
    norm = mpl.colors.BoundaryNorm(bounds, cmap.N)
    m.pcolormesh(longitude, latitude, data, latlon=True, cmap=cmap, norm=norm)
    color_bar = plt.colorbar()

    # Must reset the alpha level to opaque for the colorbar.
    # See http://stackoverflow.com/questions/4478725/...
    # .../partially-transparent-scatter-plot-but-with-a-solid-color-bar
    color_bar.set_alpha(1)
    
    # Put label in the middle.
    color_bar.set_ticks([224.0, 238.0])
    color_bar.set_ticklabels(['night', 'inland water'])
    color_bar.draw_all()

    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, long_name))
    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)

if __name__ == "__main__":

    # If a certain environment variable is set, look there for the input
    # file, otherwise look in the current directory.
    hdffile = 'MOD10_L2.A2000065.0040.006.2016058071909.hdf'
    run(hdffile)
    
