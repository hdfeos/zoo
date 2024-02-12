"""
This example code illustrates how to access and visualize a LaRC CALIPSO
LIDAR L2 PSCMask HDF4 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python CAL_LID_L2_PSCMask-Standard-V2-00.2021-03-26T00-00-00ZN.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.12 :: Miniconda
Last updated: 2022-09-29
"""
import os
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from pyhdf.SD import SD, SDC
from matplotlib import colors
from mpl_toolkits.basemap import Basemap

FILE_NAME = 'CAL_LID_L2_PSCMask-Standard-V2-00.2021-03-26T00-00-00ZN.hdf'

# Read data field.
DATAFIELD_NAME = 'PSC_Feature_Mask'

hdf = SD(FILE_NAME, SDC.READ)
        
# Read dataset.
data2D = hdf.select(DATAFIELD_NAME)
data = data2D[:,:].astype(np.float64)

# Retrieve the attributes.
attrs = data2D.attributes(full=1)
fva=attrs["fillvalue "]
fill_value = fva[0]
ua=attrs["units "]
units = ua[0]

 # Replace the missing values with NaN.        
data[data == float(fill_value)] = np.nan
datam = np.ma.masked_array(data, np.isnan(data))
    
# Read geolocation datasets.
latitude = hdf.select('Latitude')
lat = latitude[:]

longitude = hdf.select('Longitude')
lon = longitude[:]

altitude = hdf.select('Altitude')
alt = altitude[:]
attrs = altitude.attributes(full=1)
ua=attrs["units "]
alt_units = ua[0]

m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-90, urcrnrlat=90,
                llcrnrlon=-180, urcrnrlon=180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 30), labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(-180, 181, 45), labels=[0, 0, 0, 1])
sc = m.scatter(lon, lat, c=datam[:,120], s=1,
               cmap=plt.cm.jet,
               edgecolors=None, linewidth=0)
cb = m.colorbar()
cb.set_label(units)

basename = os.path.basename(FILE_NAME)
long_name = DATAFIELD_NAME + ' at Altitude=' + str(alt[120]) + alt_units
plt.title('{0}\n{1}'.format(basename, long_name))
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
    

 
