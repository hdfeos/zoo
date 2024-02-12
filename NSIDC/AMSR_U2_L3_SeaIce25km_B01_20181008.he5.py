"""

This example code illustrates how to access and visualize an NSIDC AMSR_U2 L3 
SeaIce25km HDF-EOS5 Grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python AMSR_U2_L3_SeaIce25km_B01_20181008.he5.py

The HDF-EOS5 file must be in your current working directory.

Tested under: Python 2.7.15 :: Anaconda custom (64-bit)
Last updated: 2018-10-10
"""

import os
import re
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import pyproj
import numpy as np

USE_GDAL = False

def run(FILE_NAME):

   # Identify the data field.    
    DATAFIELD_NAME = 'SI_25km_NH_89V_DAY'
    GRID_NAME = 'NpPolarGrid25km'
    if USE_GDAL:    
        import gdal
        # To list available datasets, uncomment the following two lines.        
        # ds = gdal.Open(FILE_NAME)
        # print(ds.GetSubDatasets())
        

        gname = 'HDF5:"{0}"://HDFEOS/GRIDS/{1}/Data_Fields/{2}'.format(FILE_NAME,
                                                                      GRID_NAME,
                                                                      DATAFIELD_NAME)
        gdset = gdal.Open(gname)
        data = gdset.ReadAsArray().astype(np.float64)

        # Read projection parameters from global attribute.
        meta = gdset.GetMetadata()
        print(meta)

        # GDAL doesn't utilize HDF-EOS5 library.
        # Thus, GDAL cannot set projection parameters properly.        
        x0, xinc, _, y0, _, yinc = gdset.GetGeoTransform()

        # Set manually using StructMetadata.0 dataset.
        x0 = -3850000; # Units are in m.
        x1 = 3750000;
        y0 = 5850000;
        y1 = -5350000;
        nx, ny = (gdset.RasterXSize, gdset.RasterYSize)
        xinc = (x1 - x0) / nx
        yinc = (y1 - y0) / ny
        del gdset
    else:
        import h5py
        with h5py.File(FILE_NAME, mode='r') as f:        
            name = '/HDFEOS/GRIDS/{0}/Data Fields/{1}'.format(GRID_NAME,
                                                              DATAFIELD_NAME)
            data = f[name][:].astype(np.float64)
            # Read metadata. 
            gridmeta = f['/HDFEOS INFORMATION/StructMetadata.0'][()]
            # print(gridmeta)
            
        # Construct the grid.  The needed information is in a string dataset
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

    data[data == 0] = np.nan
    data *= 0.1
    data = np.ma.masked_array(data, np.isnan(data))
    x = np.linspace(x0, x0 + xinc*nx, nx)
    y = np.linspace(y0, y0 + yinc*ny, ny)
    xv, yv = np.meshgrid(x, y)
    # See https://nsidc.org/data/au_si25/versions/1 
    pstereo = pyproj.Proj("+init=EPSG:3411")    
    wgs84 = pyproj.Proj("+init=EPSG:4326")
    # Transform EASE Grid to WGS84.
    lon, lat= pyproj.transform(pstereo, wgs84, xv, yv)
    units = 'K'
    long_name = DATAFIELD_NAME

    m = Basemap(projection='npstere', resolution='l', boundinglat=33, lon_0 = 0)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(0, 91, 20), labels=[1, 0, 0, 0])
    m.drawmeridians(np.arange(-180, 181, 45), labels=[0, 0, 0, 1])
    m.pcolormesh(lon, lat, data, latlon=True)
    cb = m.colorbar()
    cb.set_label(units)

    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, long_name))
    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)

if __name__ == "__main__":

    hdffile = 'AMSR_U2_L3_SeaIce25km_B01_20181008.he5'
    run(hdffile)
    
