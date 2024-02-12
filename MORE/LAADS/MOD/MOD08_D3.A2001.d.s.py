"""
This example code illustrates how to read multiple LAADS MOD08_D3 v6.1 
HDF-EOS2 Grid files in Python. This code subsets data for a specific region
and average them.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MOD08_D3.A2001.d.s.py

The HDF-EOS2 files must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-05-09
"""
import os
import glob

import matplotlib.pyplot as plt
import numpy as np

from pyhdf.SD import SD, SDC
from mpl_toolkits.basemap import Basemap

# Change this for a different data set.
DATAFIELD_NAME = "Aerosol_Optical_Depth_Land_Ocean_Mean"
# DATAFIELD_NAME = "Cloud_Top_Temperature_Mean"

i = 0

# Subset region.
# lon = 20 : 60 E
# lat = 0 : 30 N

latbounds = [0, 30]
lonbounds = [20, 60]

datas = None

for file in sorted(glob.glob("MOD08_D3.A200100*.061.*.hdf")):
    print(file)

    hdf = SD(file, SDC.READ)

    # Read dataset.
    data_raw = hdf.select(DATAFIELD_NAME)
    data = data_raw[:, :].astype(np.double)

    # Read lat/lon & attributes only once.
    xdim = hdf.select("XDim")
    lon = xdim[:].astype(np.double)

    ydim = hdf.select("YDim")
    lat = ydim[:].astype(np.double)
    
    # Retrieve attributes.
    attrs = data_raw.attributes(full=1)
    lna = attrs["long_name"]
    long_name = lna[0]
    aoa = attrs["add_offset"]
    add_offset = aoa[0]
    fva = attrs["_FillValue"]
    _FillValue = fva[0]
    sfa = attrs["scale_factor"]
    scale_factor = sfa[0]
    ua = attrs["units"]
    units = ua[0]

    data[data == _FillValue] = np.nan
    datam = np.ma.masked_array(data, np.isnan(data))
    datam = scale_factor * (datam - add_offset)
    
    # Subset data based on lat & lon bounds.
    lon, lat = np.meshgrid(lon, lat)
    mask = ((lat > latbounds[0]) & (lat < latbounds[1]) &
            (lon > lonbounds[0]) & (lon < lonbounds[1]))
    if i == 0:
        datas = datam[mask]
    else:
        datas = datam[mask] + datas
    i = i + 1
    
# Average data.
datas = datas / float(i)

# Draw a map.
m = Basemap(projection='cyl', resolution='l',
            llcrnrlat=-90, urcrnrlat=90,
            llcrnrlon=-180, urcrnrlon=180)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 45), labels=[True,False,False,False])
m.drawmeridians(np.arange(-180, 180, 45), labels=[False,False,False,True])

# Draw a plot.
sc = m.scatter(lon[mask], lat[mask], c=datas, s=0.1, cmap=plt.cm.jet,
                edgecolors=None, linewidth=0)

# Draw colorbar.
cb = m.colorbar()
cb.set_label(units)

# Put title.
t = "{0}\n{1}".format("MOD08_D3 2001-01-01~2001-01-03 Avg. [0~30N] & [20~60E]",
                      DATAFIELD_NAME)
plt.title(t, fontsize=8)

# Save the plot.
fig = plt.gcf()
pngfile = "MOD08_D3.A2001.d.s.py.png"
fig.savefig(pngfile)

