"""
This example code illustrates how to access and visualize a LaRC CERES SSF
NPP L2 netCDF-4/HDF5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python CER_SSF_NPP-FM5-VIIRS_Edition2A_200203.2022013123.nc.py

The netCDF-4/HDF5 file must either be in your current working directory.

Tested under: Python 3.9.12 :: Miniconda
Last updated: 2022-10-10

"""
import os
import h5py

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from mpl_toolkits.basemap import Basemap

FILE_NAME = 'CER_SSF_NPP-FM5-VIIRS_Edition2A_200203.2022013123.nc'
with h5py.File(FILE_NAME, mode='r') as f:

    latvar = f['/Time_and_Position/instrument_fov_latitude']
    latitude = latvar[:]
    
    lonvar = f['/Time_and_Position/instrument_fov_longitude']
    longitude = lonvar[:]
    
    dset_name = '/TOA_and_Surface_Fluxes/model_a_clearsky_surface_longwave_downward_flux'
    datavar = f[dset_name]
    data = np.float32(datavar[:])
    units = datavar.attrs['units']
    units = units.decode('ascii', 'replace')
    
    long_name = datavar.attrs['long_name']
    long_name = long_name.decode('ascii', 'replace')
        
    _FillValue = datavar.attrs['_FillValue']
    
    # Handle fill values.
    data[data == _FillValue] = np.nan
    data = np.ma.masked_where(np.isnan(data), data)

    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon=180)
    m.scatter(longitude, latitude, c=data, s=1, cmap=plt.cm.jet,
              edgecolors=None, linewidth=0)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90, 91, 45))
    m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
    cb = m.colorbar()
    cb.set_label(units)
    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, long_name), fontsize=8)
    pngfile = "{0}.py.png".format(basename)
    fig = plt.gcf()
    fig.savefig(pngfile)


# Reference
#  [1] https://cmr.earthdata.nasa.gov/search/concepts/C2246001739-LARC_ASDC.html

