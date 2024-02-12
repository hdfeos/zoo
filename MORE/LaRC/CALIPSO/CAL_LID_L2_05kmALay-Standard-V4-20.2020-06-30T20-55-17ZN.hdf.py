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

    $python CAL_LID_L2_05kmALay-Standard-V4-20.2020-06-30T20-55-17ZN.hdf.py

The HDF file must either be in your current working directory.

Tested under: Python 3.7.7 :: Anaconda 4.8.4
Last updated: 2020-12-02
"""

import os

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from pyhdf.SD import SD, SDC
from matplotlib import colors
from mpl_toolkits.basemap import Basemap

FILE_NAME = 'CAL_LID_L2_05kmALay-Standard-V4-20.2020-06-30T20-55-17ZN.hdf'
DATAFIELD_NAME = 'Feature_Classification_Flags'
hdf = SD(FILE_NAME, SDC.READ)
        
# Read dataset.
data2D = hdf.select(DATAFIELD_NAME)

# Select layer 0. See Table 60 (p. 109) from [1]
data = data2D[:,0]

# Read geolocation datasets.
#  For the 5 km layer products, three values are reported: the footprint latitude for the first pulse included in the 15 shot average; the footprint latitude at the temporal midpoint; and the footprint latitude for the final pulse respectively (i.e., at the 8th of 15 consecutive laser shots). [2]

latitude = hdf.select('Latitude')
lats = latitude[:]
lat = lats[:,0]
longitude = hdf.select('Longitude')
lons = longitude[:]
lon = lons[:,0]

# Subset data. Otherwise, all points look black.
lat = lat[::10]
lon = lon[::10]
data = data[::10]

# Extract Feature Type only through bitmask.
data = data & 7

# Make a color map of fixed colors.
cmap = colors.ListedColormap(['black', 'blue', 'yellow', 'green', 'red',
                              'purple', 'gray', 'white'])

# The data is global, so render in a global projection.
m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=-90, urcrnrlat=90,
            llcrnrlon=-180, urcrnrlon=180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90.,90,45))
m.drawmeridians(np.arange(-180.,180,45), labels=[True,False,False,True])
x,y = m(lon, lat)
i = 0
for feature in data:
    m.plot(x[i], y[i], 'o', color=cmap(feature),  markersize=3)
    i = i+1
long_name = 'Feature Type at Layer = 0'
basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, long_name))

fig = plt.gcf()

# Define the bins and normalize.
bounds = np.linspace(0,8,9)
norm = mpl.colors.BoundaryNorm(bounds, cmap.N)

# Create a second axes for the colorbar.
ax2 = fig.add_axes([0.93, 0.2, 0.01, 0.6])
cb = mpl.colorbar.ColorbarBase(ax2, cmap=cmap, norm=norm, spacing='proportional', ticks=bounds, boundaries=bounds, format='%1i')

cb.ax.set_yticklabels(['invalid', 'clear', 'cloud', 'aerosol', 'strato', 'surface', 'subsurf', 'no signal'], fontsize=5)

pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)

# Reference
# [1] https://www-calipso.larc.nasa.gov/products/CALIPSO_DPC_Rev4x92.pdf
# [2] https://www-calipso.larc.nasa.gov/resources/calipso_users_guide/data_summaries/layer/index_v420.php#heading02

