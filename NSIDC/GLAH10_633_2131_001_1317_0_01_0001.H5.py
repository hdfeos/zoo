"""

This example code illustrates how to access and visualize an NSIDC 
ICESat/GLAS GLAH10 L2 HDF5 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

   $python GLAH10_633_2131_001_1317_0_01_0001.H5.py

The HDF5 file must in your current working directory.

Tested under: Python 2.7.15 :: Anaconda custom (64-bit)
Last updated: 2018-10-17
"""

import os
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

# Can do this using either netCDF4 or h5py.
USE_NETCDF4 = False

def run(FILE_NAME):
    if USE_NETCDF4:
    
        from netCDF4 import Dataset
    
        nc = Dataset(FILE_NAME)

        latvar = nc.groups['Data_1HZ'].groups['Geolocation'].variables['d_lat']
        latitude = latvar[:]
        lat_vr = [latvar.valid_min, latvar.valid_max]

        lonvar = nc.groups['Data_1HZ'].groups['Geolocation'].variables['d_lon']
        longitude = lonvar[:]
        lon_vr = [lonvar.valid_min, lonvar.valid_max]

        tempvar = nc.groups['Data_1HZ'].groups['Geophysical'].variables['r_Surface_temp']
        temp = tempvar[:]
        temp_vr = [tempvar.valid_min, tempvar.valid_max]
        units = tempvar.units
        long_name = tempvar.long_name

        timevar = nc.groups['Data_1HZ'].groups['Time'].variables['d_UTCTime_1']
        time = timevar[:]

    else:
    
        import h5py
    
        with h5py.File(FILE_NAME, mode='r') as f:
    
            latvar = f['/Data_1HZ/Geolocation/d_lat']
            latitude = latvar[:]
            lat_vr = [latvar.attrs['valid_min'], latvar.attrs['valid_max']]
    
            lonvar = f['/Data_1HZ/Geolocation/d_lon']
            longitude = lonvar[:]
            lon_vr = [lonvar.attrs['valid_min'], lonvar.attrs['valid_max']]
    
            tempvar = f['/Data_1HZ/Geophysical/r_Surface_temp']
            temp = tempvar[:]
            temp_vr = [tempvar.attrs['valid_min'], tempvar.attrs['valid_max']]
            units = tempvar.attrs['units']
            long_name = tempvar.attrs['long_name']
    
            time = f['/Data_1HZ/Time/d_UTCTime_1'][:]

    # Draw an equidistant cylindrical projection using the low resolution
    # coastline database.
    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat = 90,
                llcrnrlon=-180, urcrnrlon = 180)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90., 120., 30.))
    m.drawmeridians(np.arange(-180, 180., 45.))
    longitude[longitude > 180] -= 360
    m.scatter(longitude, latitude, c=temp, s=1, cmap=plt.cm.jet,
              edgecolors=None, linewidth=0)
    cb = m.colorbar()
    cb.set_label(units)
    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, long_name))
    
    fig = plt.gcf()    
    # plt.show()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)

if __name__ == "__main__":
    hdffile = 'GLAH10_633_2131_001_1317_0_01_0001.H5'
    run(hdffile)
