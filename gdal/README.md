# Introduction

 This folder has **gdalmdimtranslate** examples for [NASA EED2 Innovation Challenge Prototype](https://bugs.earthdata.nasa.gov/browse/ICP-2). The **gdalmdimtranslate** is a new GDAL command line tool that can handle multi-dimenstional dataset and transpose data.  During the first round of challenge, we're mainly interested in testing the following products that meet the following creteria:
 
  * non HDF-EOS data products such as generic HDF4/HDF5/netCDF-4 data product.
  * Dataset that requires subsetting - 3 or more dimension dataset.

# How to contribute

0. Install [miniconda3](https://docs.conda.io/en/latest/miniconda.html) and use ```mconda3>conda install -c conda-forge gdal``` to install the latest GDAL 3.1.0 (or above) command line tools.
1. Download a sample file from [zoo](http://hdfeos.org/zoo).
2. Run *gdalmdiminfo sample.hdf > info_output.txt* to identify group and dataset. 
3. Run *gdalmdimtranslate* with *-array* parameter that corresponds to **/group/dataset** in [zoo](http://hdfeos.org/zoo) to generate GeoTIFF. Use filename.tif for file name.
4. Test GeoTIFF with either ArcGIS Pro or QGIS.
5. Update the table in the README with the parameters used, upload the converted GeoTIFF and its screenshot. Use filename.png for screenshot file name.
6. Add a note that help NASA Earthdata users.

# Table
  Although AIRS is an HDF-EOS product and can be handled by **gdal_translate**, it is given as the first example to match the main  [zoo](http://hdfeos.org/zoo) table.
| NASA Data Center | Product | Type | Parameters | Output | Plot | Note |
|------------------|---------|------|------------|--------|------|------|
| GES DISC | [AIRS](https://gamma.hdfgroup.org/ftp/pub/outgoing/NASAHDF/AIRS.2002.08.30.227.L2.RetStd_H.v6.0.12.0.G14101125810.hdf) | Swath | -array "name=/swaths/L2_Standard_atmospheric&surface_product/Data Fields/topog" | [GeoTIFF](AIRS.2002.08.30.227.L2.RetStd_H.v6.0.12.0.G14101125810.hdf.tif) | n/a | It throws an error message: ```ERROR 1: An attribute with same name already exists```. Geo-location information can't be handled properly. Use gdal_translate.|
| GES DISC | [3A26](https://gamma.hdfgroup.org/ftp/pub/outgoing/NASAHDF/3A26.20140101.7.HDF) | Grid | -array "name=" | [GeoTIFF]() | n/a | Generic HDF4 and 3D.|


