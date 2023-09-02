"""
This example code illustrates how to access, visualize, and
 convert LaRC CALIPSO L3 HDF4 files into netCDF-4 in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

$python CAL_LID_L3_Tropospheric_APro_AllSky-Standard-V4-20.2007-01D.hdf.v.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-08-31
"""

import os

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import colors
from netCDF4 import Dataset
from pyhdf.SD import SD, SDC

# Read December dataset first.
FILE_NAME = "CAL_LID_L3_Tropospheric_APro_AllSky-Standard-V4-20.2007-01D.hdf"
hdf = SD(FILE_NAME, SDC.READ)
# Print available datasets.
# print(hdf.datasets())

# Read dataset - shape: 85 (lat) x 72 (lon) x 208 (alt) x 7 (type) [1,2].
# This dataset stores counts for each type.
DATAFIELD_NAME = "Aerosol_Type"
dset = hdf.select(DATAFIELD_NAME)
data = dset[:].astype(np.double)

# Read geolocation datasets.
# They are all same for every file so we read only once.
lat = hdf.select("Latitude_Midpoint")
# Shape: Unlimited x 85
latitude = np.squeeze(lat[:])
lon = hdf.select("Longitude_Midpoint")
# Shape: Unlimited x 72
longitude = np.squeeze(lon[:])
# Shape: Unlimited x 208
alt = hdf.select("Altitude_Midpoint")
altitude = np.squeeze(alt[:])

# Apply the fill value.
fillvalue = -9999.0
data[data == fillvalue] = np.nan
data = np.ma.masked_array(data, np.isnan(data))

# Read attributes.
attrs = dset.attributes(full=1)
ua = attrs["units"]
units = ua[0]

# Create color map for discrete value map.
# Use 'white' instead of 'grey' for invalid data to match background color.
cmap = colors.ListedColormap(
    ["grey", "blue", "yellow", "orange",
     "green", "brown", "black", "aqua"]
)
basename = os.path.basename(FILE_NAME)

# Prepare a new dataset for # of location x altitude.
# The # of location is lat * lon.
data2D = np.zeros(shape=(85 * 72, 208))
data3D = np.zeros(shape=(208, 85, 72))

grids = []
i = 0
for lat in latitude:
    j = 0
    for lon in longitude:
        grids.append(f"{lat}_{lon}")  # This will be used as x label.
        max = 0  # Pick the most dominant aerosol type.
        for k in range(208):
            for t in range(7):
                if data[i][j][k][t] > 0 and data[i][j][k][t] > max:
                    data2D[i * 72 + j][k] = t+1
                    data3D[k][i][j] = t+1
                    max = data[i][j][k][t]
        j = j + 1
    i = i + 1
grids = np.array(grids)

# First 10 points:
# plt.contourf(grids[0:10], altitude, data2D[0:10, :].T, cmap=cmap)

# Every 100th points:
plt.contourf(grids[::100], altitude, data2D[::100, :].T, cmap=cmap)
long_name = DATAFIELD_NAME
plt.title("{0}\n{1}".format(basename, long_name))
ax = plt.gca()

# Move label because color bar is at the bottom.
ax.xaxis.set_label_coords(1.05, -0.05)

# Adjust label size.
ax.set_xlabel("Lat_Lon", fontsize=5)
# Create a list of x-tick labels
xl = grids[::100]
x_tick_labels = xl[::10]
# plt.tick_params(axis="x", rotation=45, labelsize=5)ww
plt.tick_params(axis="x", labelsize=5)
plt.xticks(xl[::10], x_tick_labels)
plt.ylabel("Altitude (kim)")
fig = plt.gcf()


# Define the bins and normalize for discrete colorbar.
bounds = np.linspace(0, 8, 9)
norm = mpl.colors.BoundaryNorm(bounds, cmap.N)

# Create a second axes for the discrete colorbar.
ax2 = fig.add_axes([0.1, 0.03, 0.8, 0.01])
cb = mpl.colorbar.ColorbarBase(
    ax2,
    cmap=cmap,
    norm=norm,
    orientation="horizontal",
    spacing="proportional",
    ticks=bounds,
    boundaries=bounds,
    format="%1i",
)

# Put label in the middle.
loc = bounds + 0.5
cb.set_ticks(loc[:-1])
cb.ax.set_xticklabels(
    [
        "n/a",
        "clean marine",
        "dust",
        "polluted c./s.",
        "clean c.",
        "polluted dust",
        "elevated smoke",
        "dusty marine",
    ],
    fontsize=5,
)
pngfile = "{0}.v.py.png".format(basename)
fig.savefig(pngfile)

# Save as netCDF.
_fname = FILE_NAME + ".v.nc4"
ncout = Dataset(_fname, "w", format="NETCDF4")

# Define axis size.
nlat = len(latitude)
nlon = len(longitude)
nalt = len(altitude)

ncout.createDimension("lat", nlat)
ncout.createDimension("lon", nlon)
ncout.createDimension("alt", nalt)

# Create latitude axis.
lat = ncout.createVariable("lat", np.dtype("double").char, ("lat"))
lat.standard_name = "latitude"
lat.long_name = "latitude"
lat.units = "degrees_north"
lat.axis = "Y"

# Create longitude axis.
lon = ncout.createVariable("lon", np.dtype("double").char, ("lon"))
lon.standard_name = "longitude"
lon.long_name = "longitude"
lon.units = "degrees_east"
lon.axis = "X"

# Create altitude axis.
alt = ncout.createVariable("alt", np.dtype("double").char, ("alt"))
alt.standard_name = "altitude"
alt.long_name = "altitude"
alt.units = "km"
alt.axis = "Z"

# Create variable array.
_varname = "aerosol_type"
vout = ncout.createVariable(
    _varname, np.dtype("int").char, ("alt", "lat", "lon"),
    fill_value=0
)
_long_name = long_name
vout.long_name = _long_name
vout.units = units

# Copy axis from original dataset.
lon[:] = longitude[:]
lat[:] = latitude[:]
alt[:] = altitude[:]
vout[:] = data3D[:]

# Close file.
ncout.close()



# References
#
# [1] https://www-calipso.larc.nasa.gov/resources/calipso_users_guide/data_summaries/l3/index.php
# [2] https://www-calipso.larc.nasa.gov/resources/calipso_users_guide/data_summaries/l3/cal_lid_l3_tropospheric_apro_v4-20_desc.php
