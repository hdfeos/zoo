"""
This example code illustrates how to access and visualize a GESDISC AIRS grid
in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python AIRS.2024.01.19.L3.RetStd_IR001.v7.0.7.0.G24022205217.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2024-01-31
"""

import os

import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.basemap import Basemap
from pyhdf.HDF import HC, HDF
from pyhdf.SD import SD, SDC
from pyhdf.V import V

FILE_NAME = "AIRS.2024.01.19.L3.RetStd_IR001.v7.0.7.0.G24022205217.hdf"
DATAFIELD_NAME = "Temperature_A"

hdf = SD(FILE_NAME, SDC.READ)
# List available SDS datasets.
# print hdf.datasets()

# Read dataset.
data3D = hdf.select(DATAFIELD_NAME)
data = data3D[0, :, :]

# Read geolocation dataset.
lat = hdf.select("Latitude")
latitude = lat[:, :]
lon = hdf.select("Longitude")
longitude = lon[:, :]

# Handle fill value.
attrs = data3D.attributes(full=1)
fillvalue = attrs["_FillValue"]

# fillvalue[0] is the attribute value.
fv = fillvalue[0]
data[data == fv] = np.nan
data = np.ma.masked_array(data, np.isnan(data))

# We need to use Vgroup interface to read '/location/Grid Attributes' values.
f = HDF(FILE_NAME, HC.READ)
v = f.vgstart()
vs = f.vstart()
vg = v.attach(v.find("location"))
members = vg.tagrefs()
for tag, ref in members:
    if tag == HC.DFTAG_VG:
        vg2 = v.attach(ref)
        if vg2._name == "Grid Attributes":
            members2 = vg2.tagrefs()
            for tag2, ref2 in members2:
                vd = vs.attach(ref2)
                if vd._name == "Year":
                    year = vd.read()
                if vd._name == "Month":
                    month = vd.read()
                if vd._name == "Day":
                    day = vd.read()
                vd.detach()
vg2.detach()
vg.detach()
v.end()
f.close()
date = str(year[0][0]) + "-" + str(month[0][0]) + "-" + str(day[0][0])

m = Basemap(
    projection="cyl",
    resolution="l",
    llcrnrlat=-90,
    urcrnrlat=90,
    llcrnrlon=-180,
    urcrnrlon=180,
)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(np.arange(-90, 90, 30), labels=[1, 0, 0, 0])
m.drawmeridians(np.arange(-180, 180, 30), labels=[0, 0, 0, 1])
m.pcolormesh(longitude, latitude, data, latlon=True, alpha=0.90)
cb = m.colorbar()
cb.set_label("Unit:K")
basename = os.path.basename(FILE_NAME)
plt.title(
    "{0}\n {1} at StdPrsLvls=0 on {2}".format(basename, DATAFIELD_NAME, date)
)
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
