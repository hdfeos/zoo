"""
This example code illustrates how to read multiple LAADS MOD08_D3 v6.1 
HDF-EOS2 Grid files in Python. This code subsets data for a specific region
and average them yearly.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MOD08_D3.A2001.y.py

The HDF-EOS2 files must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-04-17
"""
import os
import glob
import datetime

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

from pyhdf.SD import SD, SDC

# Change this for a different data set.
DATAFIELD_NAME = "Aerosol_Optical_Depth_Land_Ocean_Mean"
# DATAFIELD_NAME = "Cloud_Top_Temperature_Mean"

i = 0
l = []

# Subset region [1].
# lon = 20 : 60 E
# lat = 0 : 30 N

latbounds = [0, 30]
lonbounds = [20, 60]

datas = None

for file in sorted(glob.glob("MOD08_D3.A200*.061.*.hdf")):
    print(file)

    hdf = SD(file, SDC.READ)

    # Read dataset.
    data_raw = hdf.select(DATAFIELD_NAME)
    data = data_raw[:, :].astype(np.double)
    
    xdim = hdf.select("XDim")
    lon = xdim[:].astype(np.double)

    ydim = hdf.select("YDim")
    lat = ydim[:].astype(np.double)

    # Read attributes only once.
    if i == 0:
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
    data = scale_factor * (data - add_offset)
    datam = np.ma.masked_array(data, np.isnan(data))

    # Subset data / lat / lon.
    lon, lat = np.meshgrid(lon, lat)
    mask = ((lat > latbounds[0]) & (lat < latbounds[1]) &
            (lon > lonbounds[0]) & (lon < lonbounds[1]))    
    datas = datam[mask]

    m = np.nanmean(datas)
    if np.isnan(m):
        print("All values are NaN.")
    else:
        year = file[10:14]
        l.append([int(year), m])        
    i = i + 1

df = pd.DataFrame(l, columns=["Year", "Mean"])

print(df)

str_t = "MOD08_D3 Yearly Average [0~30N] & [20~60E]"
t = "{0}\n{1}".format(str_t, DATAFIELD_NAME)
plt = df.groupby("Year").mean().plot(title=t)
plt.locator_params(integer=True)


# Save image.
pngfile = "MOD08_D3.A2001.y.py.png"
fig = plt.get_figure()
fig.savefig(pngfile)

# References
# [1] https://stackoverflow.com/questions/29135885/netcdf4-extract-for-subset-of-lat-lon
