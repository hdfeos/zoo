"""
This example code illustrates how to access and visualize a LaRC CALIPSO file
in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python CAL_LID_L2_VFM-Standard-V4-51.2019-07-12T04-47-04ZD.hdf.v.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2024-01-25
"""
import os

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import colors
from pyhdf.SD import SD, SDC

FILE_NAME = "CAL_LID_L2_VFM-Standard-V4-51.2019-07-12T04-47-04ZD.hdf"

# Identify the data field.
DATAFIELD_NAME = "Feature_Classification_Flags"

hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data2D = hdf.select(DATAFIELD_NAME)
data = data2D[:, :]

# Read geolocation datasets.
latitude = hdf.select("Latitude")
lat = latitude[:]

longitude = hdf.select("Longitude")
lon = longitude[:]

t = hdf.select("Profile_UTC_Time")
utc = np.squeeze(t[:])

# Extract Ice/Water Phase only (6-7 bits) through bitmask.
data = data >> 5
data = data & 3

# Subset latitude values for the region of interest (-66N to -18N).
j = 0
for i in range(1, len(lat)):
    if (lat[i] > -18.8) and (lat[i] <= -18.7):
        j = i
        break
lat = np.squeeze(lat[0:j])
lon = np.squeeze(lon[0:j])
size = lat.shape[0]

# You can visualize other blocks by changing subset parameters.
#  data2d = data[3500:3999, 0:164]    # 20.2km to 30.1km
#  data2d = data[3500:3999, 165:1164] #  8.2km to 20.2km
#  data2d = data[3500:3999, 1165:]    # -0.5km to  8.2km
data2d = data[0:j, 1165:]  # -0.5km to  8.2km
data3d = np.reshape(data2d, (size, 15, 290))
data = data3d[:, 0, :]

# Generate altitude data according to file specification [1].
alt = np.zeros(290)

# You can visualize other blocks by changing subset parameters.
#  20.2km to 30.1km
# for i in range (0, 54):
#       alt[i] = 20.2 + i*0.18;
#  8.2km to 20.2km
# for i in range (0, 199):
#       alt[i] = 8.2 + i*0.06;
# -0.5km to 8.2km
for i in range(0, 290):
    alt[i] = -0.5 + i * 0.03

# Contour the data on a grid of latitude vs. pressure
latitude, altitude = np.meshgrid(lat, alt)
# Make a color map of fixed colors.
cmap = colors.ListedColormap(["red", "green", "blue", "grey"])

# Define the bins and normalize.
bounds = np.linspace(0, 4, 5)
norm = mpl.colors.BoundaryNorm(bounds, cmap.N)

long_name = "Ice/Water Phase"
basename = os.path.basename(FILE_NAME)
plt.contourf(latitude, altitude, np.rot90(data, 1), cmap=cmap)
num_points = 9
indx = np.linspace(0, len(lat) - 1, num_points, dtype=int)
indx1 = indx[1::]
fa = [f"Lat {lat[0]:.2f}\nLon {lon[0]:.2f}"]
fa2 = np.vectorize(lambda x, y: f"{x:.2f}\n{y:.2f}")(lat[indx1], lon[indx1])
fa = fa + list(fa2)

plt.xticks(lat[indx], fa, fontsize=8)
t = "0 = Unknown    1 = ice    2 = water    3 = oriented ice"

# Calculate hours, minutes, and seconds
fraction = utc[0] - int(utc[0])
hours = int(fraction * 24)
minutes = int((fraction * 24 * 60) % 60)
seconds = int((fraction * 24 * 60 * 60) % 60)
start = f"   UTC: {hours:02d}:{minutes:02d}:{seconds:02d}"

fraction = utc[j] - int(utc[j])
hours = int(fraction * 24)
minutes = int((fraction * 24 * 60) % 60)
seconds = int((fraction * 24 * 60 * 60) % 60)
end = f" to {hours:02d}:{minutes:02d}:{seconds:02d}"

plt.title("{0}\n{1}\n{2}".format(basename, long_name + start + end, t))
plt.xlabel("Latitude (degrees north)")
plt.ylabel("Altitude (km)")

fig = plt.gcf()

# Create a second axes for the discrete colorbar.
ax2 = fig.add_axes([0.93, 0.2, 0.03, 0.6])
cb = mpl.colorbar.ColorbarBase(
    ax2,
    cmap=cmap,
    norm=norm,
    spacing="proportional",
    ticks=bounds,
    boundaries=bounds,
)
loc = bounds + 0.5
cb.set_ticks(loc[:-1])
cb.ax.set_yticklabels(["0", "1", "2", "3"], fontsize=6)

pngfile = "{0}.v.py.png".format(basename)
fig.savefig(pngfile)
