"""

This example code illustrates how to access and visualize a NSIDC Level-2
MODIS Aqua Sinusoidal HDF-EOS2 Grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MYD10A1F.A2020131.h18v03.061.2020335131245.hdf.py

 The HDF file must be in your current working directory.

Tested under: Python 3.7.7 :: Anaconda
Last updated: 2020-12-03
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
    DATAFIELD_NAME = 'MYD10A1_NDSI_Snow_Cover'

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

    # Get lat/lon min/max for zoomed image.
    latmin = np.min(lat)-10
    latmax = np.max(lat)+10
    lonmin = np.min(lon)-5
    lonmax = np.max(lon)+5
    lon0 = (lonmax + lonmin) / 2.0
    m = Basemap(projection='cyl', 
                lon_0=lon0,
                llcrnrlat=latmin, urcrnrlat = latmax,
                llcrnrlon=lonmin, urcrnrlon = lonmax)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(latmin, latmax, 5), labels=[1, 0, 0, 0])
    m.drawmeridians(np.arange(lonmin, lonmax, 5), labels=[0, 0, 0, 1])

    lst = [
           '#ffff00', # 0-100% snow
           '#ffafff', # 200 missing
           '#000000', # 201 no decision
           '#cccccc', # 211 night
           '#00ffcc', # 237 inland water
           '#0000dd', # 239 ocean
           '#00c600', # 250 cloud
           '#ee0000', # 254 detector saturated
           '#8928dd'] # 255 fill
    cmap = mpl.colors.ListedColormap(lst)
    bounds = [0, 200, 201, 211, 237, 239, 250, 254, 255, 256]
    norm = mpl.colors.BoundaryNorm(bounds, cmap.N)
    
    # Dataset is too big. Subset to visualize data properly.
    m.pcolormesh(lon[::2,::2], lat[::2,::2], data[::2,::2], latlon=True,
                 cmap=cmap, norm=norm)
    
    color_bar = plt.colorbar(orientation='horizontal')
    color_bar.set_ticks([100, 200.5, 207, 224, 238, 244.5, 252, 254.5, 255.5])
    color_bar.set_ticklabels(['0-100%\nsnow', 'missing',
                              'no\ndecision', 'night', 'inland\nwater', 'ocean',
                              'cloud', 'detector\nsaturated',
                              'fill'])
    color_bar.draw_all()

    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, long_name))
    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)


if __name__ == "__main__":
    hdffile = 'MYD10A1F.A2020131.h18v03.061.2020335131245.hdf'
    run(hdffile)
    
