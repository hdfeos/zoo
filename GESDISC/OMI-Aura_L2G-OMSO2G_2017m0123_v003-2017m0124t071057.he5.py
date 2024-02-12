"""

This example code illustrates how to access and visualize a GESDISC OMI L2G 
HDF-EOS5 Grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

  $python OMI-Aura_L2G-OMSO2G_2017m0123_v003-2017m0124t071057.he5.py

The HDF-EOS5 file must be in your current working directory.

Tested under: Python 2.7.13 :: Anaconda 4.3.22 
Last updated: 2017-12-19
"""
import os

import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np
import h5py

FILE_NAME = 'OMI-Aura_L2G-OMSO2G_2017m0123_v003-2017m0124t071057.he5'    


with h5py.File(FILE_NAME, mode='r') as f:
    PATH_NAME = '/HDFEOS/GRIDS/OMI Total Column Amount SO2/Data Fields/'
    DATAFIELD_NAME = PATH_NAME + 'ColumnAmountSO2_PBL'
    LAT_NAME = PATH_NAME + 'Latitude'
    LON_NAME = PATH_NAME + 'Longitude'

    dset = f[DATAFIELD_NAME]
    data = dset[:]

    # Read lat/lon data.
    lat = f[LAT_NAME][:]
    lon = f[LON_NAME][:]
    
    # Get attributes needed for the plot.
    # String attributes actually come in as the bytes type and should
    # be decoded to UTF-8 (python3).
    title = dset.attrs['Title'].decode()
    units = dset.attrs['Units'].decode()
    valid_range = dset.attrs['ValidRange']
    _FillValue = dset.attrs['_FillValue']
    add_offset = dset.attrs['Offset']
    scale_factor = dset.attrs['ScaleFactor']

    # Handle fill value.
    data[data == _FillValue] = np.nan
    data = data * scale_factor + add_offset

    # Handle valid range.
    data[data < valid_range[0]] = np.nan
    data[data > valid_range[1]] = np.nan

    data = np.ma.masked_where(np.isnan(data), data)
    # Subset data at nCandidate = 0
    data = data[0,:,:]
    lon = lon[0,:,:]
    lat = lat[0,:,:]

    # Draw an equidistant cylindrical projection using the low resolution
    # coastline database.
    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat = 90,
                llcrnrlon=-180, urcrnrlon = 180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90., 120., 30.), labels=[1, 0, 0, 0])
    m.drawmeridians(np.arange(-180, 180., 45.), labels=[0, 0, 0, 1])
    m.scatter(lon, lat, c=data, s=0.1, cmap=plt.cm.jet,
              edgecolors=None, linewidth=0)
    cb = m.colorbar()
    cb.set_label(units)

    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, title+' at nCandidate=0'))

    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)

