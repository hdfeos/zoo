"""
This example code illustrates how to read multiple GES DISC 2A23 Swath
files and calculate seasonal average over South Africa region in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage: save this script and run

    $python 2A23.2013.s.py

The HDF4 files must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-09-12
"""

import glob

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from pyhdf.SD import SD, SDC

DATAFIELD_NAME = "freezH"
DATAFIELD_NAME2 = "HBB"

# Subset South Africa region.
latbounds = [-34.8191663551, -22.0913127581]
lonbounds = [16.3449768409, 32.830120477]

i = 0
_l = []

for fn in sorted(glob.glob("2A23.2013*.7.HDF")):
    print(fn)

    hdf = SD(fn, SDC.READ)
    ds = hdf.select(DATAFIELD_NAME)
    data = ds[:, :].astype(np.double)

    ds2 = hdf.select(DATAFIELD_NAME2)
    data2 = ds2[:, :].astype(np.double)

    # Handle fill values.
    fillvalue = -9999.0
    data[data == fillvalue] = np.nan

    fillvalue2 = -8888.0
    data2[data2 == fillvalue2] = np.nan
    
    # Read units attributes only once.
    if i == 0:
        attrs = ds.attributes(full=1)
        ua=attrs["units"]
        units = ua[0]

    # Retrieve the geolocation data.
    lats = hdf.select("Latitude")
    lat = lats[:, :]
    lons = hdf.select("Longitude")
    lon = lons[:, :]

    mask = (
        (lat > latbounds[0])
        & (lat < latbounds[1])
        & (lon > lonbounds[0])
        & (lon < lonbounds[1])
    )
    datas = data[mask]
    datas2 = data2[mask]

    # Calculate means.
    m = np.nanmean(datas)
    m2 = np.nanmean(datas2)

    if np.isnan(m) or np.isnan(m2):
        print("All values are NaN for either FreezH or BBH.")
    else:
        mo = int(fn[9:11])
        s = np.floor(mo / 3)
        if s == 4:
            s = 0
        print(s)        
        _l.append([s, m, m2])

    i = i + 1

# Put titles.
t = "{0}\n{1}".format("2A23 2013 Seasonal Average", DATAFIELD_NAME)
t2 = "{0}".format(DATAFIELD_NAME2)

df = pd.DataFrame(_l, columns=["Season", "Mean", "Mean2"])

print(df)

fig, axs = plt.subplots(2, 1, sharex=True)
pl = df.groupby("Season")["Mean"].mean().plot(title=t, ax=axs[0], ylabel=units)
# HBB has the same units as freezH.
p2 = df.groupby("Season")["Mean2"].mean().plot(title=t2, color="red",
                                              ax=axs[1], ylabel=units)
p2.locator_params(integer=True)
# Save the plot.
pngfile = "2A23.2013.s.py.png"
fig.savefig(pngfile)
