"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize a LAADS MYD02HKM v6
HDF-EOS2 Swath file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python MYD02HKM.A2015125.0115.006.2015125153005.hdf.py

The HDF-EOS2 file must be in your current working directory.

Tested under: Python 2.7.13 :: Anaconda 4.3.22 
Last updated: 2018-02-16
"""
import os
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
from pyhdf.SD import SD, SDC

# Open file.
FILE_NAME = 'MYD02HKM.A2015125.0115.006.2015125153005.hdf'
hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
DATAFIELD_NAME = 'EV_500_RefSB'
data_raw = hdf.select(DATAFIELD_NAME)

# Subset data.
data = data_raw[0,:,:].astype(np.double)

        
# Retrieve attributes.
attrs = data_raw.attributes(full=1)
lna=attrs["long_name"]
long_name = lna[0]
aoa=attrs["reflectance_offsets"]
add_offset = aoa[0][0]
fva=attrs["_FillValue"]
_FillValue = fva[0]
sfa=attrs["reflectance_scales"]
scale_factor = sfa[0][0]        
vra=attrs["valid_range"]
valid_min = vra[0][0]        
valid_max = vra[0][1]        
ua=attrs["reflectance_units"]
units = ua[0]

# Retrieve dimension name.
dim = data_raw.dim(0)
dimname = dim.info()[0]

invalid = np.logical_or(data > valid_max,
                        data < valid_min)
invalid = np.logical_or(invalid, data == _FillValue)
data[invalid] = np.nan
data = (data - add_offset) * scale_factor 
data = np.ma.masked_array(data, np.isnan(data))

# Read geo-location data from HDF-EOS2 dumper output.
# Run the following command to get the latitude using eos2dump tool [1].
# $eos2dump -a1 MYD02HKM.A2015125.0115.006.2015125153005.hdf > lat_MYD02HKM.A2015125.0115.006.2015125153005.output
# GEO_FILE_NAME = 'lat_MYD02HKM.A2015125.0115.006.2015125153005.output'
GEO_FILE_NAME = 'lat_MYD02HKM.A2015125.0115.006.2015125153005.output'
latitude = np.genfromtxt(GEO_FILE_NAME, delimiter=',', usecols=[0])
# Find middle location for map.
lat_m  = latitude[latitude.size/2]
latitude = latitude.reshape(data.shape)

# Run the following command to get the longitude using eos2dump tool [1].
# $eos2dump -a2 MYD02HKM.A2015125.0115.006.2015125153005.hdf > lon_MYD02HKM.A2015125.0115.006.2015125153005.output
# GEO_FILE_NAME = 'lon_MYD02HKM.A2010031.0035.005.2010031183706.output'
GEO_FILE_NAME = 'lon_MYD02HKM.A2015125.0115.006.2015125153005.output'
longitude = np.genfromtxt(GEO_FILE_NAME, delimiter=',', usecols=[0])
# Find middle location for map.
lon_m = longitude[longitude.size/2]
longitude = longitude.reshape(data.shape)

# Let's use ortho projection.
orth = ccrs.Orthographic(central_longitude=lon_m,
                         central_latitude=lat_m,
                         globe=None)
ax = plt.axes(projection=orth)

# Set global view. You can comment it out to get zoom-in view.
# ax.set_global()
p = plt.scatter(longitude, latitude, c=data, s=1, cmap=plt.cm.jet,
                edgecolors=None, linewidth=0, transform=ccrs.PlateCarree())
    
# Gridline with draw_labels=True doesn't work on Ortho projection.
# ax.gridlines(draw_labels=True)
ax.gridlines()
ax.coastlines()
cb = plt.colorbar(p)
cb.set_label(units, fontsize=8)

basename = os.path.basename(FILE_NAME)
plt.title('{0}\n{1}\n{2}\nat {3}=0'.format(basename, 'Reflectance derived from',
                                           long_name, dimname), fontsize=8)
fig = plt.gcf()

# Save file.
pngfile = "{0}.py.png".format(basename)
fig.savefig(pngfile)
    
