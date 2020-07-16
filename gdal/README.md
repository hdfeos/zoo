This folder has gdalmdimtranslate examples for [NASA EED2 Innovation Challenge Program](https://bugs.earthdata.nasa.gov/browse/ICP-2).

# How to contribute

1. Download a sample file from [zoo](http://hdfeos.org/zoo).
2. Run gdalmdiminfo. Use ```mconda3>conda install -c conda-forge gdal``` to install the latest GDAL 3.1.0 (or above) command line tools.
3. Run gdalmdimtranslate to generate GeoTIFF. Use filename.tif for file name.
4. Test GeoTIFF with either ArcGIS Pro or QGIS.
5. Update the table in the README with the parameters used, converted GeoTIFF, and screenshot. Use filename.png for screenshot file name.
6. Add a note that help NASA Earthdata users.

# Table

| NASA Data Center | Product | Type | Parameters | GeoTIFF | Plot | Note |
|------------------|---------|------|------------|---------|------|------|
| GES DISC | AIRS.2002.08.30.227.L2.RetStd_H.v6.0.12.0.G14101125810.hdf | Swath | -array  | n/a | n/a | Swath can't be handled. |


