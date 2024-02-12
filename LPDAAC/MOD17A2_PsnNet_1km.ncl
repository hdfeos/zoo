;This example code illustrates how to access and visualize LP_DAAC_MOD Grid file in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; This is an example of a 2-D grid file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin

  eos_file = addfile("MOD17A2.A2007113.h11v09.005.2007136163924.hdf", "r") ; Read file for the first time.  
  he2_file = addfile("MOD17A2.A2007113.h11v09.005.2007136163924.hdf.he2", "r") ; Read file for the second time to efficiently obtain lat and lon. 

; List available fields and attributes. 
; print(eos_file)

; read data field
  data_raw = eos_file->PsnNet_1km 

; print(data_raw)

; Filter out invalid values and set them as fill value. 
  data_valid=where(data_raw.gt.data_raw@valid_range(0) .and. data_raw.lt.data_raw@valid_range(1), data_raw, data_raw@_FillValue)

; Apply scale factor according to the field attribute 
; correct_data_value = (raw_data_value - offset) * scale
  data = (data_valid - data_raw@add_offset) * data_raw@scale_factor

  data@_FillValue = (data_raw@_FillValue - data_raw@add_offset) * data_raw@scale_factor

  data@long_name = data_raw@long_name
  data@units = data_raw@units

; Associate longitude and latitude
  data@lat2d=he2_file->GridLat_MOD_Grid_MOD17A2
  data@lon2d=he2_file->GridLon_MOD_Grid_MOD17A2

  xwks=gsn_open_wks("pdf","MOD17A2.A2007113.h11v09.005.2007136163924_PsnNet_1km_zoom.ncl") ; open workstation

  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn = False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@lbOrientation = "vertical" ;vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0; white color for missing values

  res@gsnLeftStringFontHeightF = 10 ; make font smaller
  res@gsnRightStringFontHeightF = 10 ; make font smaller

  ; the following 5 sentences are used to create a zoomed image
  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
  res@mpMaxLatF	= max(data@lat2d)
  res@mpMinLonF	= min(data@lon2d)
  res@mpMaxLonF	= max(data@lon2d)

  ;res@cnLevelSelectionMode="ManualLevels" ; preset range defined to match the valid_range metadata attribute
  ;res@cnMinLevelValF=0 ; set min and max values
  ;res@cnMaxLevelValF=3 ;

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
  res@tiMainString = "MOD17A2.A2007113.h11v09.005.2007136163924.hdf" ; create title

  res@gsnLeftString = "Field name: " + data@long_name
  res@gsnRightString = "Units: " + data@units

  plot=gsn_csm_contour_map_ce(xwks,data,res) ; create plot

; cleaning up used resources
  delete(plot)
  delete(xwks)
  delete(data_raw)
  delete(data_valid)
  delete(data)
  delete(res)
  delete(he2_file)
  delete(eos_file)

end