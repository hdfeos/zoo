"""

This example code illustrates how to access and visualize a GESDISC TRMM 3B42
HDF4 Grid version 7 file in Python. This example uses a shape file to trim plot
along a national boundary.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python 3B42.20131130.21.7.HDF.shp.py

The HDF file must be in your current working directory.

Tested under: Python 3.7.7 :: Anaconda 4.8.4
Last updated: 2020-10-23
"""
import os
import shapefile
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from pyhdf.SD import SD, SDC
from matplotlib.path import Path
from matplotlib.patches import PathPatch
from mpl_toolkits.basemap import Basemap

FILE_NAME = '3B42.20131130.21.7.HDF'
hdf = SD(FILE_NAME, SDC.READ)
DATAFIELD_NAME = 'precipitation'
ds = hdf.select(DATAFIELD_NAME)
data = ds[:].astype(np.float64)

# Handle attributes.
attrs = ds.attributes(full=1)
ua=attrs["units"]
units = ua[0]

# Consider 0.0 to be the fill value.
# Must create a masked array where nan is involved.
data[data == 0.0] = np.nan
datam = np.ma.masked_where(np.isnan(data), data)
    
# The lat and lon should be calculated manually [1].
latitude = np.arange(-49.875, 49.875, 0.249375)
longitude = np.arange(-179.875, 179.876, 0.25)


# Draw an equidistant cylindrical projection using the high resolution
# coastline database.
m = Basemap(projection='cyl')

# USA national shape file [1].
sf = shapefile.Reader("cb_2018_us_nation_20m/cb_2018_us_nation_20m.shp")
# India national shape file [2].
# sf = shapefile.Reader("gadm36_IND_shp/gadm36_IND_0.shp")

fig, ax = plt.subplots()
# You can use the following 2 lines of code insted.
# fig = plt.gcf()
# ax = fig.add_subplot(111)

for shape_rec in sf.shapeRecords():
    # print(shape_rec.record)
    # If you want to filter the shape file by region, try the following:
    #    if shape_rec.record[3] == 'Andorra':
    vertices = []
    codes = []
    pts = shape_rec.shape.points
    prt = list(shape_rec.shape.parts) + [len(pts)]
    for i in range(len(prt) - 1):
        for j in range(prt[i], prt[i+1]):
            vertices.append((pts[j][0], pts[j][1]))
        codes += [Path.MOVETO]
        codes += [Path.LINETO] * (prt[i+1] - prt[i] -2)
        codes += [Path.CLOSEPOLY]
        # These must match.
        # print(len(vertices))
        # print(len(codes))
        clip = Path(vertices, codes)
        clip = PathPatch(clip, transform=ax.transData)

cs = m.pcolormesh(longitude, latitude, datam.T, latlon=True, clip_path=clip,
                  cmap='jet')

# You can use contourf as well [3]. Use the following 3 lines of code.
#xx, yy = np.meshgrid(longitude, latitude)
#cs = m.contourf(xx, yy, datam.T)
#for contour in cs.collections:  
#         contour.set_clip_path(clip)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 91, 45))
m.drawmeridians(np.arange(-180, 180, 45), labels=[True,False,False,True])
cb = m.colorbar()
cb.set_label(units)
basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, DATAFIELD_NAME))
pngfile = "{0}.shp.py.png".format(basename)
fig.savefig(pngfile)

# Reference
# [1] https://www2.census.gov/geo/tiger/GENZ2018/shp/cb_2018_us_nation_5m.zip
# [2] https://gadm.org/download_country_v3.html
# [3] https://basemaptutorial.readthedocs.io/en/latest/clip.html 
