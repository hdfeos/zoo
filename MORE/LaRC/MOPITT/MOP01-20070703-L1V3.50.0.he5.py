"""

This example code illustrates how to access and visualize a MOPITT HDF-EOS5 Level 1
swath file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python MOP01-20070703-L1V3.50.0.he5.py

The HDF-EOS5 file must be in your current working directory.

Tested under: Python 2.7.13 :: Anaconda custom (x86_64)
Last updated: 2021-09-02

"""

import os

import h5py
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

FILE_NAME = 'MOP01-20070703-L1V3.50.0.he5'
with h5py.File(FILE_NAME, mode='r') as f:

    # Radiances data has a shape of 6349 (ntrack) x 29 (nstare) x 4 (npixesl) x 8
    # (nchan) x 2 (neng) [1].    
    name = '/HDFEOS/SWATHS/MOP01/Data Fields/MOPITTRadiances'
    data = f[name][:]

    # Process missing data. These attributes are defined in Swath group name 'MOP01'.
    missing_invalid = -8888.0
    missing_nodata = -9999.0
    data[data == missing_invalid] = np.nan
    data[data == missing_nodata] = np.nan

    # Get the geolocation data.
    # Lat/lon has fill value.
    # Latitude/Longitude dimension is 6349 (ntrack) x 29 (nstare) x 4 (npixels) [1].
    latitude = f['/HDFEOS/SWATHS/MOP01/Geolocation Fields/Latitude']
    longitude = f['/HDFEOS/SWATHS/MOP01/Geolocation Fields/Longitude']
    

    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon=180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90, 91, 45))
    m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
    for x in xrange(8):
        for y in xrange(2):
            datac = data[:,:,:,x,y]
            # Since there are many points, make point size as small as possible using
            # s=0.01 parameter.
            sc = m.scatter(longitude, latitude, c=datac, s=0.01,
                           cmap=plt.cm.jet,
                           edgecolors=None, linewidth=0)
    
    cb = m.colorbar()
    # See [2] for units.
    units = 'Watts m^-2 Sr^-1'
    cb.set_label(units)

    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, name ))
    fig = plt.gcf()
    # plt.show()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)

# References
# 
# [1] https://www.acom.ucar.edu/mopitt/file-spec.shtml#L1
# [2] https://asdc.larc.nasa.gov/project/MOPITT
