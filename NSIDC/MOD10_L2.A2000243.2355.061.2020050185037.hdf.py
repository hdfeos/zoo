"""
Copyright (C) 2014-2020 The HDF Group
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

    $python MOD10_L2.A2000243.2355.061.2020050185037.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 3.7.3 :: Anaconda (64-bit)
Last updated: 2020-03-26
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
    print(np.histogram(data))
    # print(np.max(data))
    latitude = hdf.select('Latitude')[:]
    longitude = hdf.select('Longitude')[:]
        
    # Read dataset attribute.
    attrs = data2D.attributes(full=1)
    lna = attrs["long_name"]
    long_name= lna[0]

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
    # bounds = np.array([211.0,237.0,239.0])
    bounds = np.array([0,237.0,239.0])
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
    hdffile = 'MOD10_L2.A2000243.2355.061.2020050185037.hdf'
    run(hdffile)
    
