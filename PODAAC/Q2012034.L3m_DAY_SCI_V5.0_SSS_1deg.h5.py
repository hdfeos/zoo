"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize a PO.DAAC AQUARIUS
SSS L3 grid file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python Q2012034_L3m_DAY_SCI_V5.0_SSS_1deg.h5.py

Last Update: 2019/10/18
"""

import os

import h5py
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

FILE_NAME = 'Q2012034.L3m_DAY_SCI_V5.0_SSS_1deg.h5'
    
with h5py.File(FILE_NAME, mode='r') as f:

    datavar = f['l3m_data']
    minv = f.attrs['data_minimum']
    maxv = f.attrs['data_maximum']
    
    data = datavar[:]
    fv = datavar.attrs['_FillValue']

    # The dataset doesn't have CF units/long_name attributes.
    units = 'psu'
    long_name = 'Sea Surface Salinity'

    data[data == fv] = np.nan
    
    # Handle min/max values [1].
    invalid = np.logical_or(data < minv, data > maxv)
    data[invalid] = np.nan

    x = np.linspace(-179.5, 179.5, 360)
    y = np.linspace(-89.5, 89.5, 180)[::-1]
    longitude, latitude = np.meshgrid(x, y)

    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon=180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90, 91, 45))
    m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
    sc = m.scatter(longitude, latitude, c=data, s=1, cmap=plt.cm.jet,
                   edgecolors=None, linewidth=0)

    cb = m.colorbar()
    cb.set_label(units)    

    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, long_name))
    fig = plt.gcf()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)
    
# References
#
# [1] https://podaac-tools.jpl.nasa.gov/drive/files/allData/aquarius/docs/v5/AQ-010-UG-0008_AquariusUserGuide_DatasetV5.0.pdf
