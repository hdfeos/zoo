; This example code illustrates how to access and visualize LP_DAAC_MOD Grid file in NCL. 
; If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
; If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
; Feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; This is an example of a 3-D grid file data field at various levels.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin

  eos_file = addfile("MOD43B4.A2006353.h15v15.004.2007006030047.hdf", "r") ; Read file for the first time.  
  he2_file = addfile("MOD43B4.A2006353.h15v15.004.2007006030047.hdf.he2", "r") ; Read file for the second time to efficiently obtain lat and lon. 

; List available fields and attributes. 
; print(eos_file)

; read data field
  data_raw = eos_file->Nadir_Reflectance

; print(data_raw)

; Apply scale factor according to the field attribute 
; correct_data_value = (raw_data_value - offset) * scale_factor
  data_valid = (data_raw - data_raw@add_offset) * data_raw@scale_factor

  data_valid@_FillValue = (data_raw@_FillValue - data_raw@add_offset) * data_raw@scale_factor

  data = data_valid(:,:,0) 
  data@_FillValue = data_valid@_FillValue
  data@lat2d = he2_file->GridLat_MOD_Grid_BRDF
  data@lon2d = he2_file->GridLon_MOD_Grid_BRDF

  data_1 = data_valid(:,:,2)
  data_1@_FillValue = data_valid@_FillValue
  data_1@lat2d = he2_file->GridLat_MOD_Grid_BRDF
  data_1@lon2d = he2_file->GridLon_MOD_Grid_BRDF

  data_2 = data_valid(:,:,4)
  data_2@_FillValue = data_valid@_FillValue
  data_2@lat2d = he2_file->GridLat_MOD_Grid_BRDF
  data_2@lon2d = he2_file->GridLon_MOD_Grid_BRDF

  data_3 = data_valid(:,:,6)
  data_3@_FillValue = data_valid@_FillValue
  data_3@lat2d = he2_file->GridLat_MOD_Grid_BRDF
  data_3@lon2d = he2_file->GridLon_MOD_Grid_BRDF

  xwks = gsn_open_wks("pdf","MOD43B4.A2006353.h15v15.004.2007006030047_Nadir_Reflectance_zoom.ncl") ; open workstation

  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True ; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn = False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@lbOrientation = "vertical" ;vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0; white color for missing values

  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
  res@mpMaxLatF	= max(data@lat2d) ; 
  res@mpMinLonF	= min(data@lon2d) ;
  res@mpMaxLonF	= max(data@lon2d) ;

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
  plot = new(4, "graphic") ; allocate plot
  res@tiMainString = "MOD43B4.A2006353.h15v15.004.2007006030047.hdf" ; create title
  res@gsnCenterString = "Nadir_Reflectance at Num_Land_Bands=0"
  res@gsnRightString = "reflectance, no units"
  plot(0) = gsn_csm_contour_map_ce(xwks,data,res) ; create plot
  delete(res@tiMainString) ; remove title from subsequent plots

  res@gsnCenterString = "Nadir_Reflectance at Num_Land_Bands=2"
  res@gsnRightString = "reflectance, no units"
  plot(1) = gsn_csm_contour_map_ce(xwks,data_1,res) ; create plot

  res@gsnCenterString = "Nadir_Reflectance at Num_Land_Bands=4"
  res@gsnRightString = "reflectance, no units"
  plot(2) = gsn_csm_contour_map_ce(xwks,data_2,res) ; create plot

  res@gsnCenterString = "Nadir_Reflectance at Num_Land_Bands=6"
  res@gsnRightString = "reflectance, no units"
  plot(3) = gsn_csm_contour_map_ce(xwks,data_3,res) ; create plot

  delete(plot) ; cleaning up used resources
  delete(xwks)
  delete(data_raw)
  delete(data_valid)
  delete(data)
  delete(data_1)
  delete(data_2)
  delete(data_3)
  delete(res)
  delete(he2_file)
  delete(eos_file)

end