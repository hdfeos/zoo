"""

This example code illustrates how to read multiple LAADS MOD04_3K Swath
files and calculate daily average over Ethiopia region in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MOD04_3K.A2022.d.py

The HDF files must be in your current working directory.

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2022-03-21
"""

import os
import glob

import numpy as np
import pandas as pd
import cartopy.io.shapereader as shpreader
import matplotlib as mpl
import matplotlib.path as mpltPath
import matplotlib.pyplot as plt

from pyhdf.SD import SD, SDC
from cartopy.feature import ShapelyFeature

DATAFIELD_NAME ='Optical_Depth_Land_And_Ocean'

# Read shape file.
shpfilename = shpreader.natural_earth(resolution='10m',
                                      category='cultural',
                                      name='admin_0_countries')
reader = shpreader.Reader(shpfilename)

# Select Ethiopia shape.
for country in reader.records():
    if (country.attributes['NAME'][:8] == 'Ethiopia'):
        ethiopia = country

# Ethiopia has one polygon.
path = mpltPath.Path(ethiopia.geometry.exterior.coords)

l = []

for file in sorted(glob.glob('MOD04_3K.A2022*.hdf')):
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
    datam = np.ma.masked_array(data, np.isnan(data))
    points = []
    for latit in range(0,longitude.shape[0]):
        for lonit in range(0,longitude.shape[1]):
            point = (lon[latit,lonit],lat[latit,lonit])
            points.append(point)

    # Create index.
    inside = path.contains_points(points)
    inside = np.array(inside).reshape(longitude.shape)
    i = np.where(inside == True)
    flag = not np.any(i)
    if flag:
        print('No data for the region.')
    else:
        m = np.nanmean(data[i])
        if (np.isnan(m)):
            print('All values are NaN.')
        else:
            print(m)
            day = file[14:17]
            l.append([int(day), m])
df = pd.DataFrame(l, columns=['Day', 'Mean'])
print(df)
t = '{0}\n{1}'.format('MOD04_3K 2022 Daily Average in Ethiopia', DATAFIELD_NAME)
plt = df.groupby('Day').mean().plot(title = t)
fig = plt.get_figure()

# Save image.
pngfile = "MOD04_3K.A2022.d.py.png"
fig.savefig(pngfile)
    
