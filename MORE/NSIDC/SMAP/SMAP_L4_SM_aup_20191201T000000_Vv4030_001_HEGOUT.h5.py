"""

This example code illustrates how to access and visualize a SMAP L4 SM aup
HDF5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python SMAP_L4_SM_aup_20191201T000000_Vv4030_001_HEGOUT.h5.py

This example requires an additional geolocation file.
The two HDF5 files must be in your current working directory.
  * SMAP_L4_SM_aup_20191201T000000_Vv4030_001_HEGOUT.h5
  * SMAP_L4_SM_gph_20191201T013000_Vv4030_001.h5

Tested under: Python 3.7.3 :: Anaconda custom (x86_64)
Last updated: 2020-02-07
"""

import os
import h5py

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from mpl_toolkits.basemap import Basemap


FILE_NAME = 'SMAP_L4_SM_aup_20191201T000000_Vv4030_001_HEGOUT.h5'

    
with h5py.File(FILE_NAME, mode='r') as f:
    
    name = '/Analysis_Data/sm_rootzone_analysis'
    data = f[name][:]
    units = f[name].attrs['units']
    units = units.decode('ascii', 'replace')
    long_name = f[name].attrs['long_name']
    long_name = long_name.decode('ascii', 'replace')
    _FillValue = f[name].attrs['_FillValue']
    valid_max = f[name].attrs['valid_max']
    valid_min = f[name].attrs['valid_min']        
    invalid = np.logical_or(data > valid_max,
                            data < valid_min)
    invalid = np.logical_or(invalid, data == _FillValue)
    data[invalid] = np.nan
    data = np.ma.masked_where(np.isnan(data), data)
    
    # Get the geolocation data from a different product
    # (e.g., SMAP_L4_SM_gph_20191201T013000_Vv4030_001.h5)
    # since x/y dataset have invalid values.

    GEO_FILE_NAME = 'SMAP_L4_SM_gph_20191201T013000_Vv4030_001.h5'    
    with h5py.File(GEO_FILE_NAME, mode='r') as g:
        latitude = g['/cell_lat'][:]
        longitude = g['/cell_lon'][:]
        m = Basemap(projection='cyl', resolution='l',
                    llcrnrlat=-90, urcrnrlat=90,
                    llcrnrlon=-180, urcrnrlon=180)
        m.drawcoastlines(linewidth=0.5)
        m.drawparallels(np.arange(-90, 91, 45))
        m.drawmeridians(np.arange(-180, 180, 45),
                        labels=[True,False,False,True])
        m.scatter(longitude, latitude, c=data, s=1, cmap=plt.cm.jet,
                  edgecolors=None, linewidth=0)
        cb = m.colorbar(location="bottom", pad='10%')    
        cb.set_label(units)

        basename = os.path.basename(FILE_NAME)
        plt.title('{0}\n{1}'.format(basename, long_name))
        fig = plt.gcf()
        pngfile = "{0}.py.png".format(basename)
        fig.savefig(pngfile)
