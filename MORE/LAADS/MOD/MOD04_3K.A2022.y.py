"""

This example code illustrates how to read multiple LAADS MOD04_3K Swath
files and calculate yearly average at a specific lat/lon point in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MOD04_3K.A2022.y.py

The HDF files must be in your current working directory.

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2022-03-28
"""

import os
import glob
import datetime

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

from pyhdf.SD import SD, SDC


DATAFIELD_NAME ='Optical_Depth_Land_And_Ocean'

# Subset region.
# lon = 40 : 41 E
# lat = 10 : 11 N

latbounds = [ 10 , 11 ]
lonbounds = [ 40 , 41 ]

l = []

for file in sorted(glob.glob('MOD04_3K.A*.hdf')):
    print(file)
    reader = open(file)
    hdf = SD(file, SDC.READ)
    # Read dataset.
    data2D = hdf.select(DATAFIELD_NAME)
    data = data2D[:,:].astype(np.double)
    # Read geolocation dataset.
    lat = hdf.select('Latitude')
    latitude = lat[:,:]
    lon = hdf.select('Longitude')
    longitude = lon[:,:]
    # Retrieve attributes.
    attrs = data2D.attributes(full=1)
    aoa=attrs["add_offset"]
    add_offset = aoa[0]
    fva=attrs["_FillValue"]
    _FillValue = fva[0]
    sfa=attrs["scale_factor"]
    scale_factor = sfa[0]        
    ua=attrs["units"]
    units = ua[0]
    data[data == _FillValue] = np.nan
    data = (data - add_offset) * scale_factor 

    # latitude lower and upper index
    i = ((latitude > latbounds[0]) & (latitude < latbounds[1]) &
         (longitude > lonbounds[0]) & (longitude < lonbounds[1]))
    flag = not np.any(i)
    if flag:
        print('No data for the region.')
    else:
        m = np.nanmean(data[i])
        if (np.isnan(m)):
            print('All values are NaN.')
        else:
            print(m)
            year = file[10:14]
            l.append([int(year), m])
df = pd.DataFrame(l, columns=['Year', 'Mean'])
print(df)
t = '{0}\n{1}'.format('MOD04_3K Yearly Average at 40.0E & 10.0N',
                      DATAFIELD_NAME)
plt = df.groupby('Year').mean().plot(title = t)
fig = plt.get_figure()

# Save image.
pngfile = "MOD04_3K.A2022.y.py.png"
fig.savefig(pngfile)
    
