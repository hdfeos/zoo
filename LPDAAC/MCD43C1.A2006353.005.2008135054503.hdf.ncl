; 
;  This example code illustrates how to access and visualize
;  LP DAAC MCD43C1 v5 HDF-EOS2 Grid file using NCL. 
;
;  If you have any questions, suggestions, comments  on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Tested under: NCL 6.4.0
; Last updated: 2018-03-19 


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

  file_name = "MCD43C1.A2006353.005.2008135054503.hdf"

; To read HDF-EOS2 files, .he2 is appended to the file name argument. 
; For more information, consult section 4.3.2 of [1].
  eos_file=addfile(file_name+".he2", "r")

; Uncomment the following line to print all variables and attributes.
  print(eos_file)

; Rad the same file as an HDF4 file to retrieve attributes.
  hdf4_file = addfile(file_name, "r")

; Uncomment to the following line to print all variables and attributes.
;  print(hdf4_file)

; Read data field.
  data_unscaled=eos_file->BRDF_Albedo_Parameter1_Band2_MCD_CMG_BRDF_0_05Deg

; Read all necessary attributes.
  data_hdf4=hdf4_file->BRDF_Albedo_Parameter1_Band2
  fill_value = data_hdf4@_FillValue
  long_name =  data_hdf4@long_name
  scale = data_hdf4@scale_factor
  offset = data_hdf4@add_offset
  units = data_hdf4@units
  delete(data_hdf4)
  delete(hdf4_file)


; This file contains coordinate variables that will not properly plot. 
; To properly display the data, the latitude/longitude must be remapped.
; See [2] for more information.
  lat=latGlobeFo(3600, "lat", "latitude", "degrees_north") 
  lon=lonGlobeFo(7200, "lon", "longitude", "degrees_east")

  lat=lat(::-1) ; use north-to-south latitude ordering
  lon=(/ lon - 180. /) ; Span 180W to 180E instead of 0 to 360
  lon&lon=lon ; update longitude

  data_unscaled@_FillValue=fill_value

; You cannot apply scale / offset on data_unscaled directly since the array 
; is too big and NCL will give you the fatal:NclMallocl Failed error.
  data = (data_unscaled(:,:) - offset) * scale
  data!0 = "lat" 
  data!1 = "lon" 
  data&lat = lat
  data&lon = lon
  data@long_name = long_name
  data@unit = units

  xwks = gsn_open_wks("png", file_name + ".ncl") ; open workstation

; These plot needs more memory since the array size is big.
  setvalues NhlGetWorkspaceObjectId() ; make maximum filesize larger
  "wsMaximumSize" : 200000000
  end setvalues

  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@cnLinesOn=False ; turn off contour lines
  res@gsnMaximize=True ; use entire page
  res@gsnPaperOrientation="Portrait" ; force portrait
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbLabelAutoStride=True ; ensure labels do not overlap
  res@lbOrientation = "vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0; white color for missing values
  res@gsnLeftStringFontHeightF=12 ; make text smaller
  res@gsnRightStringFontHeightF=12


  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap
  res@tiMainString=file_name ; create title
  plot=gsn_csm_contour_map_ce(xwks,data,res)  
  delete(plot) ; cleaning up resources used
  delete(res)
  delete(xwks)
  delete(data)
  delete(lat)
  delete(lon)
  delete(data_unscaled)
  delete(eos_file)
end

; References
; [1] http://hdfeos.org/software/ncl.php
; [2] http://www.ncl.ucar.edu/Applications/Scripts/regrid_10.ncl