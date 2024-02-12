;
;  This example code illustrates how to access and visualize 
; LP DAAC MCD43B4 v5 HDF-EOS2 Sinusoidal Grid file using NCL. 
;
;  If you have any questions, suggestions, comments on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Tested under: NCL 6.4.0
; Last Updated: 2018-03-19

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
; Read file as HDF4 file.
  file_name = "MCD43B4.A2007193.h25v05.005.2007211152315.hdf"
  h4_file = addfile(file_name, "r")
  
; Read file as HDF-EOS2 file to get lat/lon.
  eos_file = addfile("MCD43B4.A2007193.h25v05.005.2007211152315.hdf.he2", "r")
  
; Read dataset.
  data_raw = h4_file->Nadir_Reflectance_Band1 

; Apply scale factor and fill value.
  data = (data_raw - data_raw@add_offset) * data_raw@scale_factor
  data@_FillValue = (data_raw@_FillValue - data_raw@add_offset) * data_raw@scale_factor
  data@long_name = data_raw@long_name
  data@units = data_raw@units

; Associate longitude and latitude.
  lon = eos_file->GridLon_MOD_Grid_BRDF
  lat = eos_file->GridLat_MOD_Grid_BRDF
  data@lat2d = lat
  data@lon2d = lon

  xwks = gsn_open_wks("png", file_name + ".ncl")
  
  res=True ; plot mods desired

  res@cnFillOn=True ; enable contour fill
  res@cnLinesOn=False ; turn off contour lines
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbLabelAutoStride=True ; ensure labels do not overlap
  res@lbOrientation = "vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0; white color for missing values

; Set limit to zoom image.
  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d)
  res@mpMaxLatF	= max(data@lat2d)  
  res@mpMinLonF	= min(data@lon2d) 
  res@mpMaxLonF	= max(data@lon2d) 

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap
  
  res@tiMainString=file_name

  plot = gsn_csm_contour_map_ce(xwks,data,res) 
   
; Clean up resources.
  delete([/plot, res, xwks, data, data_raw, h4_file, eos_file/])
end