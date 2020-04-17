"""
Copyright (C) 2014-2020 The HDF Group
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize a NSIDC 
MOD10 Level 2 HDF-EOS2 Swath data file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MOD10_L2.A2003313.0610.061.2020105103247.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 3.7.3 :: Anaconda (64-bit)
Last updated: 2020-04-15
"""

import os
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from pyhdf.SD import SD, SDC
from matplotlib import colors
from mpl_toolkits.basemap import Basemap

def run(FILE_NAME):

    # Identify the data field.
    DATAFIELD_NAME = 'NDSI_Snow_Cover'
    
    hdf = SD(FILE_NAME, SDC.READ)

    # Read dataset.
    data2D = hdf.select(DATAFIELD_NAME)
    
    # Use the following for low resolution.
    # This is good for low memory machine.
    rows = slice(5, 4060, 10)
    cols = slice(5, 2708, 10)
    data = data2D[rows, cols]

    lat = hdf.select('Latitude')[:]
    lon = hdf.select('Longitude')[:]
        
    # Read dataset attribute.
    attrs = data2D.attributes(full=1)
    lna = attrs["long_name"]
    long_name= lna[0]

    # Check latitude bounds.
    min_lat = np.min(lat)
    print(min_lat)
    max_lat = np.max(lat)
    print(max_lat)

    # Check longitude bounds.
    min_lon = np.min(lon)
    print(min_lon)
    max_lon = np.max(lon)
    print(max_lon)
    
    # Find middle lon.
    lon_m = (max_lon + min_lon) / 2.0
    print(lon_m)
    
    # Draw a polar stereographic projection using the low resolution coastline
    # database. Use max_lat for southern hemisphere and max_min for northern.
    m = Basemap(projection='spstere', resolution='l', boundinglat=max_lat,
                lon_0=lon_m)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(min_lat, max_lat, 10.), labels=[1,0,0,0])
    m.drawmeridians(np.arange(-180.,181.,30.), labels=[0, 0, 0,1])

    #  Key: =
    #   0-100=ndsi snow, 200=missing data, 201=no decision, 211=night,
    #   237=inland water, 239=ocean, 250=cloud, 254=detector saturated,
    #   255=fill
    #
    # Use a discrete colormap.
    cmap = mpl.colors.ListedColormap(['lightgrey', 'red', 'orange', 'black',
                                      'blue', 'darkblue', 'yellow', 'green',
                                      'violet'])
    
    # Define the bins and normalize for discrete colorbar.
    bounds = [100, 200, 201, 211, 237, 239, 250, 254, 255, 256]
    norm = mpl.colors.BoundaryNorm(bounds, cmap.N)

    # Subset data to run faster.
    step = 1
    m.pcolormesh(lon[::step,::step], lat[::step,::step], data[::step,::step],
                 latlon=True,
                 cmap=cmap, norm=norm)    
    color_bar = plt.colorbar()

    # Must reset the alpha level to opaque for the colorbar.
    # See http://stackoverflow.com/questions/4478725/...
    # .../partially-transparent-scatter-plot-but-with-a-solid-color-bar
    color_bar.set_alpha(1)
    
    # Put label in the middle.
    color_bar.set_ticks([50, 150, 200.5, 205, 224, 238, 245, 252, 254.5, 255.5])
    color_bar.set_ticklabels(['snow', 'missing', 'no', 'night',
                              'water', 'ocean', 'cloud', 'saturated',
                              'fill'])
    color_bar.draw_all()

    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, long_name))
    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)

if __name__ == "__main__":

    # If a certain environment variable is set, look there for the input
    # file, otherwise look in the current directory.
    hdffile = 'MOD10_L2.A2003313.0610.061.2020105103247.hdf'
    run(hdffile)
    
