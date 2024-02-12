"""

This example code illustrates how to access and visualize a LaRC CALIPSO L2
 HDF4 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python CAL_LID_L2_05kmAPro-Standard-V4-21.2021-01-10T21-34-11ZN.hdf.h.py

The HDF file must either be in your current working directory.

Tested under: Python 3.9.2 :: Miniconda
Last updated: 2021-12-13
"""

import os

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from pyhdf import HDF, SD, VS
from pyhdf.SD import SD, SDC
from matplotlib import colors
from mpl_toolkits.basemap import Basemap

FILE_NAME = 'CAL_LID_L2_05kmAPro-Standard-V4-21.2021-01-10T21-34-11ZN.hdf'

hdf = HDF.HDF(FILE_NAME)
vs = hdf.vstart()

xid = vs.find('metadata')
altid = vs.attach(xid)
altid.setfields('Lidar_Data_Altitudes')
nrecs, _, _, _, _ = altid.inquire()
altitude = altid.read(nRec=nrecs)
altid.detach()
alt = altitude[0][0]

DATAFIELD_NAME = 'Extinction_Coefficient_532'

sd = SD(FILE_NAME, SDC.READ)
# Read dataset.
data2D = sd.select(DATAFIELD_NAME)

# Read attributes.
attrs = data2D.attributes(full=1)
fva=attrs["fillvalue"]
fillvalue = fva[0]
ua=attrs["units"]
units = ua[0]
vra=attrs["valid_range"]
valid_range = vra[0].split('...')

data = data2D[:,:]

# Filter fill value and valid range. See Table 66 (p. 116) from [1]
data[data == fillvalue] = np.nan

# Apply the valid_range attribute.
invalid = np.logical_or(data < float(valid_range[0]),
                        data > float(valid_range[1]))
data[invalid] = np.nan
datam = np.ma.masked_array(data, mask=np.isnan(data))

# Read geolocation datasets.
latitude = sd.select('Latitude')
lats = latitude[:]
#  For the 5 km layer products, three values are reported: the footprint latitude for the first pulse included in the 15 shot average; the footprint latitude at the temporal midpoint; and the footprint latitude for the final pulse respectively (i.e., at the 8th of 15 consecutive laser shots). [2]
lat = lats[:,0]
longitude = sd.select('Longitude')
lons = longitude[:]
lon = lons[:,0]

# Use the following if you want to plot mean value over all atltitudes.
# data = np.mean(datam, axis=1)
# long_name = 'Extinction_Coefficient_532 (mean)'

# Or use the following to pick a specific altitude.
i = 390
data = datam[:,i]
long_name = 'Extinction_Coefficient_532 at altitude = ' + str(alt[i]) + ' km'

# The data is global, so render in a global projection.
m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=-90, urcrnrlat=90,
            llcrnrlon=-180, urcrnrlon=180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90.,90,45))
m.drawmeridians(np.arange(-180.,180,45), labels=[True,False,False,True])
m.scatter(lon, lat, c=data, s=1, cmap=plt.cm.jet,
          edgecolors=None, linewidth=0)
cb = m.colorbar(location='bottom', pad='10%')
cb.set_label(units)
basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, long_name))
fig = plt.gcf()
pngfile = "{0}.h.py.png".format(basename)
fig.savefig(pngfile)

# Reference
# [1] https://www-calipso.larc.nasa.gov/products/CALIPSO_DPC_Rev4x92.pdf
# [2] https://www-calipso.larc.nasa.gov/resources/calipso_users_guide/data_summaries/layer/index_v420.php#heading02

