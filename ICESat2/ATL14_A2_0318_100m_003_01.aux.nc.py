"""
This example code illustrates how to generate 2D lat/lon from an NSIDC
ATL14 vesion 3 netCDF-4 file in Python for NCL example.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python ATL14_A2_0318_100m_003_01.aux.nc.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2024-04-02

"""

import os
import re
import h5py
import pyproj

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np

from pyproj import Transformer

FILE_NAME = 'ATL14_A2_0318_100m_003_01.nc'

with h5py.File(FILE_NAME, mode='r') as f:
    
    # Read lat/lon.
    latvar = f['/y']
    lat = latvar[:]
    lat = lat[::100]
    
    lonvar = f['/x']
    lon = lonvar[:]
    lon = lon[::100]

    # Define the source and destination projections.
    src_proj = pyproj.CRS("EPSG:3031")
    dst_proj = pyproj.CRS("EPSG:4326")
    xv, yv = np.meshgrid(lon, lat)

    # Convert the coordinates.
    t = Transformer.from_crs(src_proj, dst_proj, always_xy=True)
    x, y = t.transform(xv, yv)

# Create an HDF5 file with lat/lon.
file = h5py.File("ATL14_A2_0318_100m_003_01.aux.nc", "w")

# Create a dataset for lat.
lat_dset = file.create_dataset("lat", data=y)
lat_dset.attrs["units"] = "degrees_north"

# Create a dataset for lon.
lon_dset = file.create_dataset("lon", data=x)
lon_dset.attrs["units"] = "degrees_east"

# Close the file.
file.close()
