"""

This example code illustrates how to access and visualize a LaRC CATS HDF5 file
in Python.

If you have any questions, suggestions, or comments on this example, please use
the HDF-EOS Forum (http://hdfeos.org/forums).  If you would like to see an
example of any other NASA HDF/HDF-EOS data product that is not listed in the
HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to
contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
(http://hdfeos.org/forums).

Usage:  save this script and run

  $python CATS-ISS_L2O_D-M7.2-V1-05_05kmLay.2017-05-01T00-47-40T01-28-41UTC.hdf5.v.py

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2023-12-13

"""
import os

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import colors

import h5py

# Reduce font size because file name is long.
mpl.rcParams.update({"font.size": 8})

fn = "CATS-ISS_L2O_D-M7.2-V1-05_05kmLay.2017-05-01T00-47-40T01-28-41UTC.hdf5"

with h5py.File(fn, mode="r") as f:
    name = "/layer_descriptor/Aerosol_Type_Fore_FOV"

    data_raw = f[name]

    y_scale = 23

    data = np.zeros([data_raw.shape[0], y_scale])
    # Get the geolocation data.
    # Change 2 to 0 or 1 to check other location.
    lat = f["/geolocation/CATS_Fore_FOV_Latitude"][:, 2]
    longitude = f["/geolocation/CATS_Fore_FOV_Longitude"][:, 2]
    base_altitude = f["/layer_descriptor/Layer_Base_Altitude_Fore_FOV"]

    # Create altitude (y-axis) from -2.0 km to 20.0km.
    alt = np.linspace(-2.0, 20.0, y_scale)

    # Regrid original data based on altitude.
    inds = np.digitize(base_altitude, alt)
    for i in range(data_raw.shape[0]):
        for j in range(data_raw.shape[1]):
            data[i][inds[i][j]] = data_raw[i][j]

    # Create color map for discrete value map similar to [1].
    # Use 'white' instead of 'grey' for invalid data to match background color.
    cmap = colors.ListedColormap(
        [
            "white",
            "blue",
            "aqua",
            "yellow",
            "orange",
            "green",
            "red",
            "black",
            "brown",
        ]
    )
    basename = os.path.basename(fn)

    # Contour the data on a grid of latitude vs. altitude.
    latitude, altitude = np.meshgrid(lat, alt)
    plt.contourf(latitude, altitude, np.rot90(data, 3), cmap=cmap)
    plt.title("{0}\n{1}".format(basename, name))
    ax = plt.gca()

    # Move label to the right because color bar is at the bottom.
    ax.xaxis.set_label_coords(1.05, -0.025)
    plt.xlabel("Latitude")
    plt.ylabel("Altitude (kim)")
    fig = plt.gcf()

    # Define the bins and normalize for discrete colorbar.
    bounds = np.linspace(0, 9, 10)
    norm = mpl.colors.BoundaryNorm(bounds, cmap.N)

    # Create a second axes for the discrete colorbar.
    ax2 = fig.add_axes([0.1, 0.05, 0.8, 0.02])
    cb = mpl.colorbar.ColorbarBase(
        ax2,
        cmap=cmap,
        norm=norm,
        orientation="horizontal",
        spacing="proportional",
        ticks=bounds,
        boundaries=bounds,
        format="%1i",
    )
    # Put label in the middle.
    loc = bounds + 0.5
    cb.set_ticks(loc[:-1])

    # Read [2] for data interpretation.
    cb.ax.set_xticklabels(
        [
            "invalid",
            "marine",
            "polluted marine",
            "dust",
            "dust mixture",
            "clean/background",
            "polluted continental",
            "smoke",
            "volcanic",
        ],
        fontsize=5,
    )

    pngfile = "{0}.v.py.png".format(basename)
    fig.savefig(pngfile)

# References
# [1] https://cats.gsfc.nasa.gov/data/segment_detail/265125/
# [2] https://cats.gsfc.nasa.gov/media/docs/CATS_QS_L2O_Layer_2.00.pdf
