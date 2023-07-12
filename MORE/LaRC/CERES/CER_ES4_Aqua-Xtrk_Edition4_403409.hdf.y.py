"""
This example code illustrates how to read multiple LaRC CERES ES4
Aqua HDF4 Grid files and calculate yearly average over some region in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

    $python CER_ES4_Aqua-Xtrk_Edition4_403409.hdf.y.py

The HDF files must be in your current working directory.

Tested under: Python 3.9.13 :: Miniconda
Last updated: 2023-07-12
"""

import glob

import numpy as np
import pandas as pd
from pyhdf.HDF import HC, HDF
from pyhdf.SD import SD, SDC
from pyhdf.V import V

FILE_NAME = "CER_ES4_Aqua-Xtrk_Edition4_403409*.hdf"
VG_NAME = "2.5 Degree Regional"
VG2_NAME = "Monthly (Day) Averages"
VG3_NAME = "Total-Sky"
DATAFIELD_NAME = "Longwave flux"

# Define subset region (lon: 20E~60E & lat: 0N~30N).
latbounds = [0, 30]
lonbounds = [20, 60]

i = 0
_l = []

# Read multiple files.
for fn in sorted(glob.glob(FILE_NAME)):
    print(fn)

    f = HDF(fn, HC.READ)
    v = f.vgstart()
    vg = v.attach(v.find(VG_NAME))

    members = vg.tagrefs()
    for tag, ref in members:
        if tag == HC.DFTAG_VG:
            vg2 = v.attach(ref)
            if vg2._name == VG2_NAME:
                break

    members = vg2.tagrefs()
    for tag, ref in members:
        if tag == HC.DFTAG_VG:
            vg3 = v.attach(ref)
            if vg3._name == VG3_NAME:
                break

    members = vg3.tagrefs()
    sd = SD(fn, SDC.READ)
    for tag, ref in members:
        if tag == HC.DFTAG_NDG:
            sds = sd.select(sd.reftoindex(ref))
            name, rank, dims, type, nattrs = sds.info()

            if name == DATAFIELD_NAME:
                # Read dataset.
                data = sds[:]

                # Read attributes only once.
                if i == 0:
                    # Read attributes.
                    attrs = sds.attributes(full=1)
                    la = attrs["long_name"]
                    long_name = la[0]
                    ua = attrs["units"]
                    units = ua[0]
                    fva = attrs["_FillValue"]
                    fillvalue = fva[0]
            # Read lat & lon only once.
            if i == 0 and name == "Colatitude":
                latitude = sds[:]

            if i == 0 and name == "Longitude":
                longitude = sds[:]

            sds.endaccess()

    if i == 0:
        # Adjust lat/lon values.
        latitude = 90 - latitude
        longitude[longitude > 180] = longitude[longitude > 180] - 360

        # Set region mask.
        s = (
            (latitude > latbounds[0])
            & (latitude < latbounds[1])
            & (longitude > lonbounds[0])
            & (longitude < lonbounds[1])
        )

    # Filter fill value.
    data[data == fillvalue] = np.nan
    datam = np.ma.masked_array(data, mask=np.isnan(data))

    # Subset region.
    datas = datam[s]

    # Calculate mean value.
    m = np.mean(datas)
    if np.isnan(m):
        print("All values are NaN.")
    else:
        year = fn[34:38]
        _l.append([int(year), m])

    vg3.detach()
    vg2.detach()
    vg.detach()
    v.end()
    f.close()

    i = i + 1

df = pd.DataFrame(_l, columns=["Year", "Mean"])
print(df)
t = "{0}\n{1}\n{2} over lon: 20E~60E & lat: 0N~30N region ".format(
    FILE_NAME, long_name, DATAFIELD_NAME
)
pl = df.groupby("Year").mean().plot(title=t)
pl.locator_params(integer=True)

# Save the plot.
pngfile = FILE_NAME.replace("*", "") + ".y.py.png"
fig = pl.get_figure()
fig.savefig(pngfile)
