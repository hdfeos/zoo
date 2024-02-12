"""

This example code illustrates how to access, merge, subset, and visualize
multiple LAADS MODIS swath files in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MOD06_L2_merge.s.py

The HDF files must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-04-20
"""
import os
import glob                                                                 
import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

FILE_NAME = 'MOD06_L2.A2021292.1705.061.2021293014619.hdf'
DATAFIELD_NAME = 'cloud_top_pressure_1km'

from pyhdf.SD import SD, SDC

i = 0
for file in list(glob.glob('MOD03*.hdf')):
    reader = open(file)
    hdf = SD(file, SDC.READ)
    # Read geolocation dataset.
    lat = hdf.select('Latitude')
    latitude = lat[:,:]
    lon = hdf.select('Longitude')
    longitude = lon[:,:]
    if i == 0 :
        latitude_m = latitude
        longitude_m = longitude
    else:
        latitude_m = np.vstack([latitude_m, latitude])
        longitude_m = np.vstack([longitude_m, longitude])
    i = i + 1
    
i = 0    
for file in list(glob.glob('MOD06*.hdf')):
    reader = open(file)
    hdf = SD(file, SDC.READ)
    # Read dataset.
    data2D = hdf.select(DATAFIELD_NAME)
    data = data2D[:,:].astype(np.double)
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
    else:
        data_m = np.vstack([data_m, datam])
    i = i + 1

# Subset region.
# lon = 60 : 80 E
# lat = 20 : 30 N
latbounds = [ 20 , 30 ]
lonbounds = [ 60 , 80 ]

i = ((latitude_m > latbounds[0]) & (latitude_m < latbounds[1]) &
     (longitude_m > lonbounds[0]) & (longitude_m < lonbounds[1]))

flag = not np.any(i)
if flag:
    print('No data for the region.')
        
datas = data_m[i]
lons = longitude_m[i]
lats = latitude_m[i]

m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon=180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 30), labels=[True,False,False,False])
m.drawmeridians(np.arange(-180, 180, 45), labels=[False,False,False,True])
sc = m.scatter(lons, lats, c=datas, s=0.1, cmap=plt.cm.jet,
               edgecolors=None, linewidth=0)
cb = m.colorbar()
cb.set_label(units)


# Put title using the first file.
basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, DATAFIELD_NAME))
fig = plt.gcf()

# Save image.
pngfile = "{0}.merge.s.py.png".format(basename)
fig.savefig(pngfile)
    
