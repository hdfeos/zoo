"""
This example code illustrates how to read multiple LaRC MISR EBAF
AS AEROSOL files in Python. This code subsets data for a specific region
and average them.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MISR_AM1_AS_AEROSOL_P142.nc.s.py

The netCDF-4/HDF5 files must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-10-26
"""
import glob

import cartopy.crs as ccrs
import matplotlib.pyplot as plt
import numpy as np
from pyresample.geometry import GridDefinition, SwathDefinition
from pyresample.kd_tree import resample_nearest

import h5py

i = 0
datas = np.empty(0)

# Set bounds for India region.
latbounds = [8.4, 37.6]
lonbounds = [68.7, 97.25]

# Set radius_of_influence in meters.
ri = 10000

# Define GridDefinition.
# 0.1 degree is about 10.11km, which is close enough to native resolution.
cellSize = 0.1
min_lon = lonbounds[0]
max_lon = lonbounds[1]
min_lat = latbounds[0]
max_lat = latbounds[1]
x0, xinc, y0, yinc = (min_lon, cellSize, max_lat, -cellSize)
nx = int(np.floor((max_lon - min_lon) / cellSize))
ny = int(np.floor((max_lat - min_lat) / cellSize))
x = np.linspace(x0, x0 + xinc * nx, nx)
y = np.linspace(y0, y0 + yinc * ny, ny)
lon_g, lat_g = np.meshgrid(x, y)
grid_def = GridDefinition(lons=lon_g, lats=lat_g)

tname = ""
for f in sorted(glob.glob("MISR_AM1_AS_AEROSOL_P142*.nc")):
    tname = tname + f + "\n"

    with h5py.File(f, mode="r") as f:
        # Read data.
        var = f["/4.4_KM_PRODUCTS/Aerosol_Optical_Depth"]
        data = var[:]
        lat = f["/4.4_KM_PRODUCTS/Latitude"][:]
        lon = f["/4.4_KM_PRODUCTS/Longitude"][:]

        # Read attributes.
        units = var.attrs["units"].decode()
        long_name = var.attrs["long_name"].decode()

        # Handle fill value.
        fillvalue = var.attrs["_FillValue"]
        data[data == fillvalue] = np.nan
        data = np.ma.masked_array(data, np.isnan(data))

        s = (
            (lat > latbounds[0])
            & (lat < latbounds[1])
            & (lon > lonbounds[0])
            & (lon < lonbounds[1])
        )
        flag = not np.any(s)
        if flag:
            print("No data for the region.")
        # Define SwathDefinition.
        lat_s = lat[s]
        lon_s = lon[s]
        swathDef = SwathDefinition(lons=lon_s, lats=lat_s)
        datag = resample_nearest(
            swathDef,
            data[s],
            grid_def,
            radius_of_influence=ri,
            epsilon=0.5,
            fill_value=np.nan,
        )
        datas = np.append(datas, datag)
        i = i + 1

# Average data.
datas_3d = np.reshape(datas, (i, datag.shape[0], datag.shape[1]))
data_nm = np.nanmean(datas_3d, axis=0)

# Plot data
m = plt.axes(projection=ccrs.PlateCarree())
m.coastlines()
m.gridlines()
p = plt.pcolormesh(lon_g, lat_g, data_nm, transform=ccrs.PlateCarree())
cb = plt.colorbar(p)
cb.set_label(units)

basename = "MISR_AM1_AS_AEROSOL_P142.nc"
plt.title("{0}{1}".format(tname, long_name), fontsize=8)
fig = plt.gcf()
pngfile = "{0}.s.py.png".format(basename)
fig.savefig(pngfile)
