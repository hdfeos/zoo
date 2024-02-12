"""
Copyright (C) 2014 John Evans

This example code illustrates how to access and visualize a LAADS MODIS swath
file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    python MOD21KM_EV_Band26.py

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
    GEO_FILE_NAME = 'MOD03.A2000055.0000.005.2010029175839.hdf'
    GEO_FILE_NAME = os.path.join(os.environ['HDFEOS_ZOO_DIR'], GEO_FILE_NAME)
    DATAFIELD_NAME = 'EV_Band26'

    if USE_NETCDF4:    
        from netCDF4 import Dataset    
        nc = Dataset(FILE_NAME)
        var = nc.variables[DATAFIELD_NAME]

        # Have to be very careful of the scaling equation here.
        # We'll turn autoscaling off in order to correctly scale the data.
        # Also need to subset the data to match the lat/lon dimensions.
        var.set_auto_maskandscale(False)
        data = var[:,:].astype(np.double)

        # Retrieve the geolocation data from MOD03 product.
        nc_geo = Dataset(GEO_FILE_NAME)
        longitude = nc_geo.variables['Longitude'][:]
        latitude = nc_geo.variables['Latitude'][:]

        # Retrieve attributes.
        scale_factor = var.radiance_scales
        add_offset = var.radiance_offsets
        _FillValue = var._FillValue
        valid_min = var.valid_range[0]
        valid_max = var.valid_range[1]
        long_name = var.long_name
        units = var.radiance_units

    else:
        from pyhdf.SD import SD, SDC
        hdf = SD(FILE_NAME, SDC.READ)

        # Read dataset.
        data2D = hdf.select(DATAFIELD_NAME)
        data = data2D[:,:].astype(np.double)

        hdf_geo = SD(GEO_FILE_NAME, SDC.READ)

        # Read geolocation dataset from MOD03 product.
        lat = hdf_geo.select('Latitude')
        latitude = lat[:,:]
        lon = hdf_geo.select('Longitude')
        longitude = lon[:,:]
        
        # Retrieve attributes.
        attrs = data2D.attributes(full=1)
        lna=attrs["long_name"]
        long_name = lna[0]
        aoa=attrs["radiance_offsets"]
        add_offset = aoa[0]
        fva=attrs["_FillValue"]
        _FillValue = fva[0]
        sfa=attrs["radiance_scales"]
        scale_factor = sfa[0]        
        vra=attrs["valid_range"]
        valid_min = vra[0][0]        
        valid_max = vra[0][1]        
        ua=attrs["radiance_units"]
        units = ua[0]
        
    invalid = np.logical_or(data > valid_max,
                            data < valid_min)
    invalid = np.logical_or(invalid, data == _FillValue)
    data[invalid] = np.nan
    data = (data - add_offset) * scale_factor 
    data = np.ma.masked_array(data, np.isnan(data))
    
    # Render the plot in a lambert equal area projection.
    m = Basemap(projection='laea', resolution='l', lat_ts=65,
                lat_0=65, lon_0=-35,
                width=3000000,height=2500000)
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(50., 91., 10.), labels=[1, 0, 0, 0])
    m.drawmeridians(np.arange(-180, 181., 30), labels=[0, 0, 0, 1])
    m.pcolormesh(longitude, latitude, data, latlon=True)
    cb=m.colorbar()
    cb.set_label(units, fontsize=8)

    basename = os.path.basename(FILE_NAME)
    plt.title('{0}\n{1}'.format(basename, 'Radiance derived from ' + long_name))
    fig = plt.gcf()
    # plt.show()
    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)


if __name__ == "__main__":

    # If a certain environment variable is set, look there for the input
    # file, otherwise look in the current directory.
    hdffile = 'MOD021KM.A2000055.0000.005.2010041143816.hdf'
    try:
        hdffile = os.path.join(os.environ['HDFEOS_ZOO_DIR'], hdffile)
    except KeyError:
        pass

    run(hdffile)
    
