"""
This example code illustrates how to read multiple GES DISC 3B42 Grid
files and calculate daily average over some region in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage: save this script and run

    $python 3B42_Daily.20190101.7.nc4.d.py

The HDF5 files must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-05-08
"""

import glob
import h5py
import os

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np

from mpl_toolkits.basemap import Basemap

DATAFIELD_NAME = "precipitation"

# Subset region.
# lon = 20 : 60 E
# lat = 0 : 30 N
latbounds = [0, 30]
lonbounds = [20, 60]

i = 0
l = []

for fn in sorted(glob.glob("3B42_Daily.2019010*.7.nc4")):
    print(fn)

    # Subset based on region.
    with h5py.File(fn, mode='r') as f:
        
        # Read dataset.
        datavar = f[DATAFIELD_NAME]
        data = datavar[:]
        
        # Read lat/lon & attributes only once.
        if i == 0:

            latvar = f['lat']
            lat1 = latvar[:]
    
            lonvar = f['lon']
            lon1 = lonvar[:]

            units = datavar.attrs['units']
            long_name= datavar.attrs['long_name']
            lat, lon = np.meshgrid(lat1, lon1)

        # Add them all together.
        if i == 0:
            datam = data
        else:
            datam = datam + data
    i = i + 1

# Average data.
datam = datam / float(i)

# Subset region.
s = ((lat > latbounds[0]) & (lat < latbounds[1]) &
     (lon > lonbounds[0]) & (lon < lonbounds[1]))
flag = not np.any(s)
if flag:
    print('No data for the region.')
        
datas = datam[s]
lons = lon[s]
lats = lat[s]

# Draw a map.
m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=-90, urcrnrlat=90,
            llcrnrlon=-180, urcrnrlon=180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 45), labels=[True,False,False,False])
m.drawmeridians(np.arange(-180, 180, 45), labels=[False,False,False,True])

# Draw a plot.
sc = m.scatter(lons, lats, c=datas, s=0.1, cmap=plt.cm.jet,
                edgecolors=None, linewidth=0)

# Draw colorbar.
cb = m.colorbar()
cb.set_label(units[0])

# Put title.
t = "{0}\n{1}".format("3B42 2019 Daily Average from Jan 1 to Jan 3",
                      long_name[0])
plt.title(t, fontsize=8)

# Save the plot.
fig = plt.gcf()
pngfile = "3B42_Daily.20190101.7.nc4.d.py.png"
fig.savefig(pngfile)
