"""

This example code illustrates how to access and visualize a LaRC CALIPSO L2
 v4.20 HDF4 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python CAL_LID_L2_05kmCLay-Standard-V4-20.2015-01-01T07-36-23ZN.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2024-09-03
"""

import os

import matplotlib.pyplot as plt
import numpy as np
from pyhdf.SD import SD, SDC

FILE_NAME = "CAL_LID_L2_05kmCLay-Standard-V4-20.2015-01-01T07-36-23ZN.hdf"
DATAFIELD_NAME = "Column_Integrated_Attenuated_Backscatter_532"

sd = SD(FILE_NAME, SDC.READ)

# Read dataset.
data2D = sd.select(DATAFIELD_NAME)

# Read attributes.
attrs = data2D.attributes(full=1)
fva = attrs["fillvalue"]
fillvalue = fva[0]
ua = attrs["units"]
units = ua[0]
vra = attrs["valid_range"]
valid_range = vra[0].split("...")

data0 = data2D[:, :]
# Filter fill value and valid range.
data0[data0 == fillvalue] = np.nan
invalid = np.logical_or(
    data0 < float(valid_range[0]), data0 > float(valid_range[1])
)
data0[invalid] = np.nan


# Read geolocation datasets.
latitude = sd.select("Latitude")
lat0 = latitude[:, 0]

longitude = sd.select("Longitude")
lon0 = longitude[:, 0]

# Read altitude. We will use Top over Base since confidence is higher [1].
altitude = sd.select("Layer_Top_Altitude")
alt0 = altitude[:, 0]

# Read time dataset.
t = sd.select("Profile_UTC_Time")
utc0 = np.squeeze(t[:, 0])

sd.end()


# Subset UAE latitude range: [22.5N, 26N].
# Filter altitude fill value (-9999.0).
latbounds = [22.5, 26]
mask = (lat0 > latbounds[0]) & (lat0 < latbounds[1]) & (alt0 != -9999.0)
lat = lat0[mask]
lon = lon0[mask]
data = data0[mask]
utc = utc0[mask]
alt = alt0[mask]

plt.scatter(lat, alt, c=data)
cb = plt.colorbar()
cb.set_label(units)

num_points = 9
indx = np.linspace(0, len(lat) - 1, num_points, dtype=int)
indx1 = indx[0:8:]
fa = [f"Lat {lat[-1]:.2f}\nLon {lon[-1]:.2f}"]
fa2 = np.vectorize(lambda x, y: f"{x:.2f}\n{y:.2f}")(lat[indx1], lon[indx1])
fa = list(fa2) + fa

plt.xticks(lat[indx], fa, fontsize=8)

# Calculate hours, minutes, and seconds.
fraction = utc[0] - int(utc[0])
hours = int(fraction * 24)
minutes = int((fraction * 24 * 60) % 60)
seconds = int((fraction * 24 * 60 * 60) % 60)
start = f"   UTC: {hours:02d}:{minutes:02d}:{seconds:02d}"

fraction = utc[-1] - int(utc[-1])
hours = int(fraction * 24)
minutes = int((fraction * 24 * 60) % 60)
seconds = int((fraction * 24 * 60 * 60) % 60)
end = f" to {hours:02d}:{minutes:02d}:{seconds:02d}"

long_name = DATAFIELD_NAME
basename = os.path.basename(FILE_NAME)
plt.title("{0}\n{1}".format(basename, long_name + start + end), fontsize=10)
plt.xlabel("Latitude (degrees north)")
plt.ylabel("Altitude (km)")

fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)

# Reference
# [1] https://www-calipso.larc.nasa.gov/resources/calipso_users_guide/data_summaries/layer/index_v420.php
