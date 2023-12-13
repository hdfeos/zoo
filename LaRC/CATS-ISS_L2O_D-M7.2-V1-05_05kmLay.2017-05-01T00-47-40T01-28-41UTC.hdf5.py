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

  $python CATS-ISS_L2O_D-M7.2-V1-05_05kmLay.2017-05-01T00-47-40T01-28-41UTC.hdf5.py

Tested under: Python 3.9.1 :: Miniconda
Last updated: 2023-12-13

"""
import os

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import colors
from mpl_toolkits.basemap import Basemap

import h5py

# Reduce font size because file name is long.
mpl.rcParams.update({"font.size": 8})


fn = "CATS-ISS_L2O_D-M7.2-V1-05_05kmLay.2017-05-01T00-47-40T01-28-41UTC.hdf5"

with h5py.File(fn, mode="r") as f:
    name = "/layer_descriptor/Aerosol_Type_Fore_FOV"

    # Change 0 to other value to visualize other layer.
    data = f[name][:, 0]

    # Get the geolocation data.
    # Change 2 to 0 or 1 to check other location.
    latitude = f["/geolocation/CATS_Fore_FOV_Latitude"][:, 2]
    longitude = f["/geolocation/CATS_Fore_FOV_Longitude"][:, 2]

    # Create color map for discrete value map similar to [1].
    cmap = colors.ListedColormap(
        [
            "grey",
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
    m = Basemap(
        projection="cyl",
        resolution="l",
        llcrnrlat=-90,
        urcrnrlat=90,
        llcrnrlon=-180,
        urcrnrlon=180,
    )
    m.drawcoastlines(linewidth=0.5)
    m.drawparallels(np.arange(-90, 91, 45))
    m.drawmeridians(np.arange(-180, 180, 45), labels=[True, False, False, True])
    m.scatter(
        longitude,
        latitude,
        c=data,
        s=1,
        cmap=cmap,
        edgecolors=None,
        linewidth=0,
    )

    basename = os.path.basename(fn)
    plt.title("{0}\n{1} at Layer 0".format(basename, name))
    fig = plt.gcf()

    # Define the bins and normalize for discrete colorbar.
    bounds = np.linspace(0, 9, 10)
    norm = mpl.colors.BoundaryNorm(bounds, cmap.N)

    # Create a second axes for the discrete colorbar.
    ax2 = fig.add_axes([0.1, 0.1, 0.8, 0.02])
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
            "p. marine",
            "dust",
            "dust mixture",
            "clean/bg",
            "p. continental",
            "smoke",
            "volcanic",
        ],
        fontsize=5,
    )

    pngfile = "{0}.py.png".format(basename)
    fig.savefig(pngfile)

# References
# [1] https://cats.gsfc.nasa.gov/data/segment_detail/265125/
# [2] https://cats.gsfc.nasa.gov/media/docs/CATS_QS_L2O_Layer_2.00.pdf
