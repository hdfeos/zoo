"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize a LAADS MYD (MODIS-
AQUA) swath file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python MYD021KM_EV_1KM_Emissive_level0.py

The HDF file must either be in your current working directory or in a directory
specified by the environment variable HDFEOS_ZOO_DIR.

The netcdf library must be compiled with HDF4 support in order for this example
code to work.  Please see the README for details.
"""

import os

import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np

USE_NETCDF4 = False

def run(FILE_NAME):
    GEO_FILE_NAME = 'MYD03.A2002226.0000.005.2009193071127.hdf'
    GEO_FILE_NAME = os.path.join(os.environ['HDFEOS_ZOO_DIR'], GEO_FILE_NAME)
    DATAFIELD_NAME = 'EV_1KM_Emissive'

    if USE_NETCDF4:    
        from netCDF4 import Dataset    
        nc = Dataset(FILE_NAME)

        # Just read the first level, Band 20.
        # lat/lon resolution.
        data = nc.variables[DATAFIELD_NAME][0,:,:].astype(np.float64)

        # Retrieve the geolocation data from MYD03 product.
        nc_geo = Dataset(GEO_FILE_NAME)
        longitude = nc_geo.variables['Longitude'][:]
        latitude = nc_geo.variables['Latitude'][:]

        # Retrieve attributes.
        units = nc.variables[DATAFIELD_NAME].radiance_units
        long_name = nc.variables[DATAFIELD_NAME].long_name

        # The scale and offset attributes do not have standard names in this 
        # case, so we have to apply the scaling equation ourselves.
        scale_factor = nc.variables[DATAFIELD_NAME].radiance_scales[0]
        add_offset = nc.variables[DATAFIELD_NAME].radiance_offsets[0]
        valid_range = nc.variables[DATAFIELD_NAME].valid_range
        _FillValue = nc.variables[DATAFIELD_NAME]._FillValue
        valid_min = valid_range[0]
        valid_max = valid_range[1]

        # Retrieve dimension name.
        dimname = nc.variables[DATAFIELD_NAME].dimensions[0]

    else:
        from pyhdf.SD import SD, SDC
        hdf = SD(FILE_NAME, SDC.READ)

        # Read dataset.
        data3D = hdf.select(DATAFIELD_NAME)
        data = data3D[0,:,:].astype(np.double)

        hdf_geo = SD(GEO_FILE_NAME, SDC.READ)

        # Read geolocation dataset from MOD03 product.
        lat = hdf_geo.select('Latitude')
        latitude = lat[:,:]
        lon = hdf_geo.select('Longitude')
        longitude = lon[:,:]
        
        # Retrieve attributes.
        attrs = data3D.attributes(full=1)
        lna=attrs["long_name"]
        long_name = lna[0]
        aoa=attrs["radiance_offsets"]
        add_offset = aoa[0][0]
        fva=attrs["_FillValue"]
        _FillValue = fva[0]
        sfa=attrs["radiance_scales"]
        scale_factor = sfa[0][0]        
        vra=attrs["valid_range"]
        valid_min = vra[0][0]        
        valid_max = vra[0][1]        
        ua=attrs["radiance_units"]
        units = ua[0]


        # Retrieve dimension name.
        dim = data3D.dim(0)
        dimname = dim.info()[0]

    invalid = np.logical_or(data > valid_max,
                            data < valid_min)
    invalid = np.logical_or(invalid, data == _FillValue)
    data[invalid] = np.nan
    data = (data - add_offset) * scale_factor 
    data = np.ma.masked_array(data, np.isnan(data))
    
    # The data is close to the equator in Africa, so a global projection is
    # not needed.
    m = Basemap(projection='cyl', resolution='l',
                llcrnrlat=-5, urcrnrlat=30, llcrnrlon=5, urcrnrlon=45)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(0, 50, 10), labels=[1, 0, 0, 0])
    m.drawmeridians(np.arange(0, 50., 10), labels=[0, 0, 0, 1])
    m.pcolormesh(longitude, latitude, data, latlon=True)
    cb=m.colorbar()
    cb.set_label(units, fontsize=8)

    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}\nat {2}=0'.format(basename, 'Radiance derived from ' + long_name, dimname), fontsize=11)
    fig = plt.gcf()
    # plt.show()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)


if __name__ == "__main__":

    # If a certain environment variable is set, look there for the input
    # file, otherwise look in the current directory.
    hdffile = 'MYD021KM.A2002226.0000.005.2009193222735.hdf'
    try:
        hdffile = os.path.join(os.environ['HDFEOS_ZOO_DIR'], hdffile)
    except KeyError:
        pass

    run(hdffile)
    
