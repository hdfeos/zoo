"""
Copyright (C) 2020 The HDF Group

This example code illustrates how to access a GESDISC MERRA file in Python
and save it as an netCDF-4 file. Then, it reads it back to write an
equivalent HDF4 file.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python MERRA300.prod.assim.inst3_3d_chm_Ne.20021201.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 3.7.3 :: Anaconda
Last updated: 2020-4-06
"""
import os
import numpy as np
from netCDF4 import Dataset
from pyhdf.SD import SD, SDC

def write_netcdf4(_fname, _lat, _lon, _data, _varname, _long_name, _units):
    # Open a netCDF file to write.
    ncout = Dataset(_fname, 'w', format='NETCDF4')
    
    # Define axis size.
    nlat = len(_lat)
    nlon = len(_lon)    
    ncout.createDimension('lat', nlat)
    ncout.createDimension('lon', nlon)
    
    # Create latitude axis.
    lat = ncout.createVariable('lat', np.dtype('double').char, ('lat'))
    lat.standard_name = 'latitude'
    lat.long_name = 'latitude'
    lat.units = 'degrees_north'
    lat.axis = 'Y'
    
    # Create longitude axis.
    lon = ncout.createVariable('lon', np.dtype('double').char, ('lon'))
    lon.standard_name = 'longitude'
    lon.long_name = 'longitude'
    lon.units = 'degrees_east'
    lon.axis = 'X'

    # Create variable array.
    vout = ncout.createVariable(_varname, np.dtype('double').char,
                                ('lat', 'lon'))
    vout.long_name = _long_name
    vout.units = _units
    # Copy axis from original dataset.
    lon[:] = _lon[:]
    lat[:] = _lat[:]
    vout[:] = _data[:]

    # Close file.
    ncout.close()

def write_hdf(_fname, _lat, _lon, _data, _var_name, _long_name, _units):
    # Create file.
    d = SD(_fname, SDC.WRITE|SDC.CREATE) 

    # Create lat.
    nlat = len(_lat)
    lat = d.create('lat', SDC.FLOAT64, nlat)
    d0 = lat.dim(0)
    d0.setname('YDim:EOSGRID')
    lat[:] = _lat
    setattr(lat, 'units', 'degrees_north')
    
    # Create lon
    nlon = len(_lon)    
    lon = d.create('lon', SDC.FLOAT64, nlon)
    d1 = lon.dim(0)    
    d1.setname('XDim:EOSGRID')
    lon[:] = _lon
    setattr(lon, 'units', 'degrees_east')
    
    # Create var.
    v = d.create(_var_name, SDC.FLOAT64, (nlat, nlon))
    v0 = v.dim(0)
    v1 = v.dim(1)
    v0.setname('YDim:EOSGRID')
    v1.setname('XDim:EOSGRID')
    v[:] = _data    
    setattr(v, 'long_name', _long_name)
    setattr(v, 'units', _units)

    # Close datasets.
    v.endaccess()
    lon.endaccess()
    lat.endaccess()
    d.end()
    
    
    
FILE_NAME = 'MERRA300.prod.assim.inst3_3d_chm_Ne.20021201.hdf'
DATAFIELD_NAME = 'PLE'
    
# Read HDF4 file.
hdf = SD(FILE_NAME, SDC.READ)

# Read dataset.
data4D = hdf.select(DATAFIELD_NAME)

# Subset data.
data = data4D[0,72,:,:].astype(np.float64)

# Retrieve the attributes.
attrs = data4D.attributes(full=1)
mva=attrs["missing_value"]
missing_value = mva[0]
lna=attrs["long_name"]
long_name = lna[0]
ua=attrs["units"]
units = ua[0]        

# Read geolocation dataset.
lat = hdf.select('YDim')
latitude = lat[:]
lon = hdf.select('XDim')
longitude = lon[:]

# Replace the missing values with NaN.        
data[data == missing_value] = np.nan
datam = np.ma.masked_array(data, np.isnan(data))

# Close datasets.
lat.endaccess()
lon.endaccess()
data4D.endaccess()

# Close file.
hdf.end()

# Write netCDF-4 file.
write_netcdf4(FILE_NAME+'.nc4', latitude, longitude, datam, DATAFIELD_NAME,
              long_name, units)
             
# Read netCDF-4 file.
nc = Dataset(FILE_NAME+'.nc4')
data = nc.variables[DATAFIELD_NAME][:, :].astype(np.float64)
    
# Retrieve the attributes.
# missing_value = nc.variables[DATAFIELD_NAME].missing_value
long_name = nc.variables[DATAFIELD_NAME].long_name
units = nc.variables[DATAFIELD_NAME].units

# Retrieve the geolocation data.
latitude = nc.variables['lat'][:]
longitude = nc.variables['lon'][:]

# Write HDF4 file.
write_hdf(FILE_NAME+'.nc4.hdf', latitude, longitude, data, DATAFIELD_NAME,
          long_name, units)

    
    

