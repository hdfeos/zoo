"""

This example code illustrates how to access and visualize a LAADS MODIS swath
file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MOD04_L2_merge.py

The HDF files must be in your current working directory.

Tested under: Python 2.7.15 :: Anaconda custom (64-bit)
Last updated: 2018-11-01
"""
import os
import glob                                                                 
import matplotlib as mpl
import matplotlib.pyplot as plt
# import cartopy.crs as ccrs
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

FILE_NAME = 'MOD04_L2.A2015014.1220.006.2015034193424.hdf'
DATAFIELD_NAME = 'Optical_Depth_Land_And_Ocean'

from pyhdf.SD import SD, SDC

i = 0

for file in list(glob.glob('MOD04*.hdf')):
    reader = open(file)
    hdf = SD(file, SDC.READ)
    # Read dataset.
    data2D = hdf.select(DATAFIELD_NAME)
    data = data2D[:,:].astype(np.double)
    # Read geolocation dataset.
    lat = hdf.select('Latitude')
    latitude = lat[:,:]
    lon = hdf.select('Longitude')
    longitude = lon[:,:]
    # Retrieve attributes.
    attrs = data2D.attributes(full=1)
    aoa=attrs["add_offset"]
    add_offset = aoa[0]
    fva=attrs["_FillValue"]
    _FillValue = fva[0]
    sfa=attrs["scale_factor"]
    scale_factor = sfa[0]        
    ua=attrs["units"]
    units = ua[0]
    data[data == _FillValue] = np.nan
    data = (data - add_offset) * scale_factor 
    datam = np.ma.masked_array(data, np.isnan(data))
    if i == 0 :
        data_m = datam
        latitude_m = latitude
        longitude_m = longitude
    else:
        data_m = np.vstack([data_m, datam])
        latitude_m = np.vstack([latitude_m, latitude])
        longitude_m = np.vstack([longitude_m, longitude])
    i = i + 1

m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon=180)
m.drawcoastlines(linewidth=0.5)
m.drawcountries(linewidth=0.3)
m.drawparallels(np.arange(-90, 91, 45))
m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
sc = m.scatter(longitude_m, latitude_m, c=data_m, s=0.1, cmap=plt.cm.jet,
                edgecolors=None, linewidth=0)
cb = m.colorbar()
cb.set_label(units)


# Put title using the first file.
basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, DATAFIELD_NAME))
fig = plt.gcf()

# Save image.
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
    
