"""

This example code illustrates how to read multiple LP DAAC MOD14 Swath
files and calculate daily average at a specific lat/lon point in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MOD14.A2023.d.py

The HDF files must be in your current working directory.

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2023-12-04
"""

import datetime
import glob

import numpy as np
import pandas as pd
from pyhdf.SD import SD, SDC

DATAFIELD_NAME = "fire mask"
GEO_FILE_NAME = "MOD03.A2023221.0750.061.2023221131337.hdf"

# Subset Hawaii region.
# latbounds = [ 18.0, 29.0 ]
# lonbounds = [ -178.0, -154.0 ]

# Subset Maui region.
latbounds = [20.0, 22.0]
lonbounds = [-157.0, -155.0]

li = []

for file in sorted(glob.glob("MOD14.A2023*.hdf")):
    print(file)
    dtv = file[6:23]

    reader = open(file)
    hdf = SD(file, SDC.READ)

    # Open the corresponding geolocation MOD03 file.
    fnp = "MOD03." + dtv + "*"
    for file_geo in sorted(glob.glob(fnp)):
        # It should print only one file name.
        print(file_geo)
        hdf_geo = SD(file_geo, SDC.READ)
        # Read geolocation dataset.
        lat = hdf_geo.select("Latitude")
        latitude = lat[:, :]
        lon = hdf_geo.select("Longitude")
        longitude = lon[:, :]

    # Read dataset.
    data2D = hdf.select(DATAFIELD_NAME)
    data = data2D[:, :].astype(np.double)

    # Retrieve attributes.
    attrs = data2D.attributes(full=1)
    lna = attrs["legend"]
    long_name = lna[0]
    # print(long_name)
    vra = attrs["valid_range"]
    valid_min = vra[0][0]
    valid_max = vra[0][1]

    invalid = np.logical_or(data > valid_max, data < valid_min)
    data[invalid] = np.nan
    data = np.ma.masked_array(data, np.isnan(data))

    # Filter fire based on the legend attribute & lat/lon bounds.
    #
    # 0 missing input data
    # 1 not processed (obsolete)
    # 2 not processed (obsolete)
    # 3 non-fire water
    # 4 cloud
    # 5 non-fire land
    # 6 unknown
    # 7 fire (low confidence)
    # 8 fire (nominal confidence)
    # 9 fire (high confidence)
    i = (
        (latitude > latbounds[0])
        & (latitude < latbounds[1])
        & (longitude > lonbounds[0])
        & (longitude < lonbounds[1])
        & (data > 6)
    )
    flag = not np.any(i)
    if flag:
        print("No fire data for the region.")
        m = 0
    else:
        m = np.nanmean(data[i])
        if np.isnan(m):
            print("All values are NaN.")
            m = 0
    day = file[11:14]
    year = file[7:11]
    date_str = f"{year}-{int(day):03}"  # Pad day with leading zeros
    date_obj = datetime.datetime.strptime(date_str, "%Y-%j")
    li.append([date_obj, m])

df = pd.DataFrame(li, columns=["Day", "Mean"])
print(df)

t = "{0}\n{1}".format("MOD14 2023 Daily Average in Maui", DATAFIELD_NAME)
pl = df.groupby("Day").mean().plot(title=t)
fig = pl.get_figure()

# Save image.
pngfile = "MOD14.A2023.d.py.png"
fig.savefig(pngfile)
