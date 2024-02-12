"""
This example code illustrates how to access and visualize a LAADS MODIS swath
file in Python using cartopy.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $conda install -c conda-forge cartopy
    $python MOD04_L2_merge.z.py

The HDF files must be in your current working directory.

Tested under: Python 3.9.1 :: Miniconda3
Last updated: 2022-03-16
"""
import os
import glob                                                                 
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
import cartopy.feature as cf
import numpy as np

FILE_NAME = 'MOD04_L2.A2015014.1220.006.2015034193424.hdf'
DATAFIELD_NAME = 'Optical_Depth_Land_And_Ocean'

from pyhdf.SD import SD, SDC

i = 0

for file in list(glob.glob('MOD04*.hdf')):
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
    if i == 0 :
        data_m = datam
        latitude_m = latitude
        longitude_m = longitude
    else:
        data_m = np.vstack([data_m, datam])
        latitude_m = np.vstack([latitude_m, latitude])
        longitude_m = np.vstack([longitude_m, longitude])
    i = i + 1

ax = plt.axes(projection = ccrs.Mercator())
ax.add_feature(cf.COASTLINE)
ax.add_feature(cf.BORDERS)
p = plt.scatter(longitude_m, latitude_m, c=data_m, s=0.1, cmap=plt.cm.jet, transform=ccrs.PlateCarree())
cb = plt.colorbar(p)
cb.set_label(units)

# Put title using the first file.
basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}'.format(basename, DATAFIELD_NAME))
fig = plt.gcf()

# Save image.
pngfile = "{0}.z.py.png".format(basename)
fig.savefig(pngfile)
    
