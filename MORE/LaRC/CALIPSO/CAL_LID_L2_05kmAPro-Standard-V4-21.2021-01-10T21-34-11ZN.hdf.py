"""

This example code illustrates how to access and visualize a LaRC CALIPSO L2
 HDF4 file in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python CAL_LID_L2_05kmAPro-Standard-V4-21.2021-01-10T21-34-11ZN.hdf.py

The HDF file must be in your current working directory.

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2021-11-02
"""

import os
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
from pyhdf import HDF, SD, VS
from pyhdf.SD import SD, SDC

FILE_NAME = 'CAL_LID_L2_05kmAPro-Standard-V4-21.2021-01-10T21-34-11ZN.hdf'
DATAFIELD_NAME = 'Extinction_Coefficient_532'
sd = SD(FILE_NAME, SDC.READ)
hdf = HDF.HDF(FILE_NAME)
vs = hdf.vstart()

xid = vs.find('metadata')
altid = vs.attach(xid)
altid.setfields('Lidar_Data_Altitudes')
nrecs, _, _, _, _ = altid.inquire()
altitude = altid.read(nRec=nrecs)
altid.detach()
alt = np.array(altitude[0][0])

# Read dataset.
data2D = sd.select(DATAFIELD_NAME)

# Read attributes.
attrs = data2D.attributes(full=1)
fva=attrs["fillvalue"]
fillvalue = fva[0]
ua=attrs["units"]
units = ua[0]
vra=attrs["valid_range"]
valid_range = vra[0].split('...')

data = data2D[:,:]
# Filter fill value and valid range. See Table 66 (p. 116) from [1]
data[data == fillvalue] = np.nan

# Apply the valid_range attribute.
invalid = np.logical_or(data < float(valid_range[0]),
                        data > float(valid_range[1]))
data[invalid] = np.nan
datam = np.ma.masked_array(data, mask=np.isnan(data))
datam = np.mean(datam, axis=0)
vs.end()
sd.end()

plt.plot(datam, alt)
plt.ylabel('Altitude (km)')
title = 'Extinction_Coefficient_532'
basename = os.path.basename(FILE_NAME)
plt.xlabel('{0} ({1})'.format('mean', units))
plt.title('{0}\n{1}'.format(basename, title))
fig = plt.gcf()
pngfile = "{0}.py.png".format(basename)

fig.savefig(pngfile)

# Reference
# [1] https://www-calipso.larc.nasa.gov/products/CALIPSO_DPC_Rev4x92.pdf


