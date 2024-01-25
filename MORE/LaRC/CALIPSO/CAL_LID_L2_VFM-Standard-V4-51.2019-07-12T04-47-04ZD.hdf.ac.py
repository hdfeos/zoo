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

    $python CAL_LID_L2_VFM-Standard-V4-51.2019-07-12T04-47-04ZD.hdf.ac.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2024-01-25
"""
import os

import matplotlib.pyplot as plt
import numpy as np
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

# Extract 1-3. Trosophic aerosol = 3.
data_ft = data & 7
data[data_ft > 3] = 0
data[data_ft < 3] = 0

# Extract Feature sub-type (10-12 bits) through bitmask.
data = data >> 9
data = data & 7

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

# Make a color map of fixed colors.
cmap = ["black", "blue", "yellow", "green", "red", "pink", "purple", "grey"]

# Define labels.
yl = [
    "not\ndetermined",
    "clear\nmarine",
    "dust",
    "polluted\ncontinental",
    "clear\ncontinental",
    "polluted\ndust",
    "smoke",
    "other",
]

# Count subtype occurrences along altitude.
subtype_counts_along_altitude = np.zeros((8, alt.size), dtype=int)
for subtype in range(0, 8):
    for i in range(0, 290):
        row = data[:, 289 - i]
        k = np.count_nonzero(row == subtype)
        subtype_counts_along_altitude[subtype][i] = k
    if subtype > 0:
        plt.plot(
            subtype_counts_along_altitude[subtype],
            alt,
            color=cmap[subtype],
            label=yl[subtype],
        )
sp = f"Lat={lat[0]:.2f}&Lon={lon[0]:.2f}"
ep = f"Lat={lat[j-1]:.2f}&Lon={lon[j-1]:.2f}"
long_name = "Aerosol Type count"
loc = "from " + sp + " to " + ep
basename = os.path.basename(FILE_NAME)

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

plt.title("{0}\n{1}\n{2}\n{3}".format(basename, long_name, loc, start + end))
plt.xlabel("Count")
plt.ylabel("Altitude (km)")
plt.legend()

fig = plt.gcf()
pngfile = "{0}.ac.py.png".format(basename)
fig.savefig(pngfile)
