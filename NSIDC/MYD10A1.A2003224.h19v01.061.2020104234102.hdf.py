"""
Copyright (C) 2014-2020 The HDF Group
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize a NSIDC 
MYD10A1 L3 HDF-EOS2 Sinusoidal Grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MYD10A1.A2003224.h19v01.061.2020104234102.hdf.py

 The HDF file must be in your current working directory.

Tested under: Python 3.7.3 :: Anaconda custom (64-bit)
Last updated: 2020-04-14
"""

import os
import re
import pyproj

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
    
USE_GDAL = False

def run(FILE_NAME):
    
    # Identify the data field.
    DATAFIELD_NAME = 'NDSI_Snow_Cover'

    if USE_GDAL:    
        import gdal
        GRID_NAME = 'MOD_Grid_Snow_500m'
    
        gname = 'HDF4_EOS:EOS_GRID:"{0}":{1}:{2}'.format(FILE_NAME,
                                                         GRID_NAME,
                                                         DATAFIELD_NAME)
        gdset = gdal.Open(gname)

        data = gdset.ReadAsArray()

        # Construct the grid.
        meta = gdset.GetMetadata()
        long_name = meta['long_name']
        x0, xinc, _, y0, _, yinc = gdset.GetGeoTransform()
        nx, ny = (gdset.RasterXSize, gdset.RasterYSize)

        del gdset

    else:
        from pyhdf.SD import SD, SDC
        hdf = SD(FILE_NAME, SDC.READ)

        # Read dataset.
        data2D = hdf.select(DATAFIELD_NAME)
        data = data2D[:,:].astype(np.float64)

        # Read global attribute.
        fattrs = hdf.attributes(full=1)
        ga = fattrs["StructMetadata.0"]
        gridmeta = ga[0]

        # Read dataset attribute.
        attrs = data2D.attributes(full=1)
        lna = attrs["long_name"]
        long_name= lna[0]
            
        # Construct the grid.  The needed information is in a global attribute
        # called 'StructMetadata.0'.  Use regular expressions to tease out the
        # extents of the grid. 
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
        ny, nx = data.shape
        xinc = (x1 - x0) / nx
        yinc = (y1 - y0) / ny


    x = np.linspace(x0, x0 + xinc*nx, nx)
    y = np.linspace(y0, y0 + yinc*ny, ny)
    xv, yv = np.meshgrid(x, y)

    # In basemap, the sinusoidal projection is global, so we won't use it.
    # Instead we'll convert the grid back to lat/lons.
    sinu = pyproj.Proj("+proj=sinu +R=6371007.181 +nadgrids=@null +wktext")
    wgs84 = pyproj.Proj("+init=EPSG:4326") 
    lon, lat= pyproj.transform(sinu, wgs84, xv, yv)

    # There's a wraparound issue for the longitude, as part of the tile extends
    # over the international dateline, and pyproj wraps longitude values west
    # of 180W (< -180) into positive territory.  Basemap's pcolormesh method
    # doesn't like that.
    lon[lon > 0] -= 360

    # Check latitude bounds.
    min_lat = np.min(lat)
    print(min_lat)
    max_lat = np.max(lat)
    print(max_lat)

    min_lon = np.min(lon)
    print(min_lon)
    max_lon = np.max(lon)
    print(max_lon)
    lon_m = (max_lon + min_lon) / 2.0
    print(lon_m)
    
    # Count the number of ocean and cloud data points to validate plot.
    print(np.histogram(data[(data < 251) & (data > 238)]))
    # You can use sinusoidal Basemap here but theimage will be too small.
    # Sinusoidal map desn't allow lat/lon limits to have zoom-in effect.
    # Thus, we will use North Polar stereo.
    # Bounding latitude should be minimum latitude value.
    m = Basemap(projection='npstere', resolution='l', boundinglat=min_lat,
                lon_0=lon_m)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(0, 91, 20), labels=[1, 0, 0, 0])
    m.drawmeridians(np.arange(-180, 180, 30), labels=[0, 0, 0, 1])
    # Key :
    # 0-100=NDSI snow, 200=missing data, 201=no decision, 211=night,
    # 237=inland water, 239=ocean, 250=cloud, 254=detector saturated,
    # 255=fill
    # Use a discretized colormap. See [1] for color names.
    cmap = mpl.colors.ListedColormap(['lightgrey', 'red', 'orange', 'black',
                                      'blue', 'darkblue', 'yellow', 'green',
                                      'violet'])
    bounds = [100, 200, 201, 211, 237, 239, 250, 254, 255, 256]
    norm = mpl.colors.BoundaryNorm(bounds, cmap.N)
    
    # 2400x2400 seems to be too big, so we'll subset it.
    m.pcolormesh(lon[::2,::2], lat[::2,::2], data[::2,::2], latlon=True,
                 cmap=cmap, norm=norm)
    color_bar = plt.colorbar()
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
    hdffile = 'MYD10A1.A2003224.h19v01.061.2020104234102.hdf'
    run(hdffile)
    
# Reference
# [1] https://matplotlib.org/3.1.0/gallery/color/named_colors.html
