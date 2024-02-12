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

    $python 3B42_Daily.201901.7.nc4.d.py

The netCDF-4 files must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-06-02
"""

import glob

import numpy as np
import pandas as pd

import h5py

DATAFIELD_NAME = "precipitation"

# Subset region.
# lon = 20 : 60 E
# lat = 0 : 30 N
latbounds = [0, 30]
lonbounds = [20, 60]

i = 0
_l = []

for fn in sorted(glob.glob("3B42_Daily.2019010*.7.nc4")):
    print(fn)

    # Subset based on region.
    with h5py.File(fn, mode="r") as f:
        # Read dataset.
        datavar = f[DATAFIELD_NAME]
        data = datavar[:]

        # Read lat/lon & attributes only once.
        if i == 0:
            latvar = f["lat"]
            lat1 = latvar[:]

            lonvar = f["lon"]
            lon1 = lonvar[:]

            units = datavar.attrs["units"]
            long_name = datavar.attrs["long_name"]
            lat, lon = np.meshgrid(lat1, lon1)
            mask = (
                (lat > latbounds[0])
                & (lat < latbounds[1])
                & (lon > lonbounds[0])
                & (lon < lonbounds[1])
            )
        datas = data[mask]
        # Calculate mean.
        m = np.mean(datas)
        if np.isnan(m):
            print("All values are NaN.")
        else:
            day = fn[17:19]
            print(day)
        _l.append([int(day), m])
    i = i + 1

# Put title.
a = long_name[0].split("with")
t = "{0}\n{1}\n{2}".format(
    "3B42 2019 Daily Average from Jan 1 to Jan 3", a[0], "with " + a[1]
)

df = pd.DataFrame(_l, columns=["Day", "Mean"])

print(df)

pl = df.groupby("Day").mean().plot(title=t)
pl.locator_params(integer=True)

# Save the plot.
pngfile = "3B42_Daily.201901.7.nc4.d.py.png"
fig = pl.get_figure()
fig.savefig(pngfile)
