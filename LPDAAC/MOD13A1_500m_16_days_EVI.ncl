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

  eos_file = addfile("MOD13A1.A2007257.h09v05.005.2007277183254.hdf", "r") ; Read file for the first time.  
  he2_file = addfile("MOD13A1.A2007257.h09v05.005.2007277183254.hdf.he2", "r") ; Read file for the second time to efficiently obtain lat and lon. 

; List available fields and attributes. 
; print(eos_file)

; read data field
  data_raw = eos_file->500m_16_days_EVI 

; print(data_raw)

; Apply scale factor according to the field attribute 
; correct_data_value = (raw_data_value - offset) / scale_factor
  data = (data_raw - data_raw@add_offset) / data_raw@scale_factor

  data@_FillValue = (data_raw@_FillValue - data_raw@add_offset) / data_raw@scale_factor

  data@long_name = data_raw@long_name
  data@units = data_raw@units

; Associate longitude and latitude
  data@lat2d = he2_file->GridLat_MODIS_Grid_16DAY_500m_VI
  data@lon2d = he2_file->GridLon_MODIS_Grid_16DAY_500m_VI

  xwks = gsn_open_wks("pdf","MOD13A1.A2007257.h09v05.005.2007277183254_500m_16_days_EVI.ncl") ; open workstation

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

  res@gsnLeftStringFontHeightF = 18 ; make font smaller
  res@gsnRightStringFontHeightF = 18 ; make font smaller

  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
  res@mpMaxLatF	= max(data@lat2d)
  res@mpMinLonF	= min(data@lon2d)
  res@mpMaxLonF	= max(data@lon2d)

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
  res@tiMainString = "MOD13A1.A2007257.h09v05.005.2007277183254.hdf" ; create title

  res@gsnLeftString = "Field name: " + data@long_name
  res@gsnRightString = "Units: " + data@units

  plot=gsn_csm_contour_map_ce(xwks,data,res) ; create plot

; cleaning up used resources
  delete(plot)
  delete(xwks)
  delete(data_raw)
  delete(data)
  delete(res)
  delete(he2_file)
  delete(eos_file)

end