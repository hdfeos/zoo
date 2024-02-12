"""
This example code illustrates how to access and visualize a LP DAAC VNP09GA
HDF-EOS5 Sinusoidal projection Grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python VNP09GA.A2020305.h30v07.001.2020306101330.h5.py

The HDF5 file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-08-21
"""
import os
import re
import h5py
import pyproj

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from mpl_toolkits.basemap import Basemap

FILE_NAME = 'VNP09GA.A2020305.h30v07.001.2020306101330.h5'
GRID_NAME = 'VNP_Grid_500m_2D'
DATAFIELD_NAME = 'SurfReflect_I3_1'

with h5py.File(FILE_NAME, mode='r') as f:        
        name = '/HDFEOS/GRIDS/{0}/Data Fields/{1}'.format(GRID_NAME,
                                                          DATAFIELD_NAME)
        data = f[name][:].astype(np.float64)

        # Read attributes.
        scale = f[name].attrs['Scale']
        offset = f[name].attrs['Offset']
        units = f[name].attrs['units'].decode()
        fill_value = f[name].attrs['_FillValue']
        long_name = f[name].attrs['long_name'].decode()
        
        # Read metadata. 
        gridmeta = f['/HDFEOS INFORMATION/StructMetadata.0'][()]
        s = gridmeta.decode('UTF-8')
        
        # Construct the grid.  The needed information is in a string dataset
        # called 'StructMetadata.0'.  Use regular expressions to retrieve
        # extents of the grid. 
        ul_regex = re.compile(r'''UpperLeftPointMtrs=\((?P<upper_left_x>[+-]?\d+\.\d+),(?P<upper_left_y>[+-]?\d+\.\d+)\)''', re.VERBOSE)
        match = ul_regex.search(s)
        x0 = np.float(match.group('upper_left_x')) 
        y0 = np.float(match.group('upper_left_y')) 
        lr_regex = re.compile(r'''LowerRightMtrs=\(
        (?P<lower_right_x>[+-]?\d+\.\d+)
        ,
        (?P<lower_right_y>[+-]?\d+\.\d+)
        \)''', re.VERBOSE)
        match = lr_regex.search(s)
        x1 = np.float(match.group('lower_right_x'))
        y1 = np.float(match.group('lower_right_y'))
        ny, nx = data.shape
        x = np.linspace(x0, x1, nx, endpoint=False)
        y = np.linspace(y0, y1, ny, endpoint=False)
        xv, yv = np.meshgrid(x, y)

        sinu = pyproj.Proj("+proj=sinu +R=6371007.181 +nadgrids=@null +wktext")
        wgs84 = pyproj.Proj("+init=EPSG:4326") 
        lon, lat = pyproj.transform(sinu, wgs84, xv, yv)        
        
        # Apply fill value and scale factor.
        data[data == fill_value] = np.nan
        data = scale * data + offset
        data = np.ma.masked_array(data, np.isnan(data))

        # Create a zoomed plot.
        m = Basemap(projection='cyl', resolution='l',
                    llcrnrlat=np.min(lat), urcrnrlat = np.max(lat),
                    llcrnrlon=np.min(lon), urcrnrlon = np.max(lon))
        # This zoomed-in location doesn't have coast lines.
        # m.drawcoastlines(linewidth=0.5)
        m.drawparallels(np.arange(np.floor(np.min(lat)), np.ceil(np.max(lat)), 1),
                        labels=[1, 0, 0, 0])
        m.drawmeridians(np.arange(np.floor(np.min(lon)), np.ceil(np.max(lon)), 2),
                        labels=[0, 0, 0, 1])
        m.pcolormesh(lon, lat, data, latlon=True)
        cb = m.colorbar()
        cb.set_label(units)
        
        basename = os.path.basename(FILE_NAME)
        plt.title('{0}\n{1}'.format(basename, long_name))
        fig = plt.gcf()
        pngfile = "{0}.py.png".format(basename)
        fig.savefig(pngfile)
