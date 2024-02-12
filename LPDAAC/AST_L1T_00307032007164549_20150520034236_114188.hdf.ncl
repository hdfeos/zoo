; 
; This example code illustrates how to access and visualize LP DAAC AST_L1T v3
; HDF-EOS2 Swath file in NCL.
;
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Usage:save this script and run 
; 
; $ncl AST_L1T_00307032007164549_20150520034236_114188.hdf.ncl
;
; Tested under: NCL 6.4.0
; Last updated: 2018-03-15

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; Read data file.
  file_name="AST_L1T_00307032007164549_20150520034236_114188.hdf"
  eos_file=addfile(file_name+".he2", "r")
  
; Remove comment to print the file content.
;  print(eos_file)

; Read data field.
   data = eos_file->ImageData4_SWIR_Swath

  dimsize=dimsizes(data)
  nlon=dimsize(0) 
  nlat=dimsize(1)
  
; Create geolocation dataset from HDF-EOS2 dumper output.
;  
; Use the following command:
;
; $eos2dump -a1 AST_L1T_00307032007164549_20150520034236_114188.hdf SWIR_Swath > lat_AST_L1T_00307032007164549_20150520034236_114188.output
  lat=asciiread("lat_AST_L1T_00307032007164549_20150520034236_114188.output",(/nlon,nlat/),"float")
  
; Use the following command:
;
; $eos2dump -a2 AST_L1T_00307032007164549_20150520034236_114188.hdf SWIR_Swath > lon_AST_L1T_00307032007164549_20150520034236_114188.output  
  lon=asciiread("lon_AST_L1T_00307032007164549_20150520034236_114188.output",(/nlon,nlat/),"float")

  data@lat2d=lat
  data@lon2d=lon

  xwks = gsn_open_wks("png", file_name + ".ncl") ; open workstation

  res = True ; plot mods desired
  
  res@cnFillOn = True ; enable contour fill
  res@cnFillMode = "RasterFill" ; faster
  res@cnLineLabelsOn = False ; turn off contour line labels  
  res@cnLinesOn = False ; turn off contour lines
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0 ; white color for missing values
  
  res@gsnMaximize = True ; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@gsnLeftStringFontHeightF = 11 ; make font smaller

  res@lbOrientation = "vertical" ; vertical labels
  res@lbLabelAutoStride = True ; ensure no label overlap

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") 

  res@mpProjection = "Orthographic"
  res@mpLimitMode = "LatLon"
; Set limits of map.
  res@mpMinLatF	= min(data@lat2d)
  res@mpMaxLatF	= max(data@lat2d)
  res@mpMinLonF	= min(data@lon2d)
  res@mpMaxLonF	= max(data@lon2d)
  res@mpGridAndLimbOn     = True ; Put Grid lines
; Change map center.
  res@mpCenterLonF        = lon(nlon/2, nlat/2)
  res@mpCenterLatF        = lat(nlon/2, nlat/2)
  res@mpFillOn = False
  
; Show latitude values.
  res@pmTickMarkDisplayMode = "Always"
  
  res@tiMainString = file_name
  res@trGridType = "TriangularMesh"
  plot = gsn_csm_contour_map(xwks,data,res)
  
; Clean up resources used.
  delete([/plot,res,xwks,eos_file/])
  delete([/data/])
end
