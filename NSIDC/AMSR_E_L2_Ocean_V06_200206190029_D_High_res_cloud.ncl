;This example code illustrates how to access and visualize NSIDC_AMSR Swath file in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; This is an example of a 2-D swath file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin

  eos_file = addfile("AMSR_E_L2_Ocean_V06_200206190029_D.hdf", "r") ; Read file for the first time.  
  he2_file = addfile("AMSR_E_L2_Ocean_V06_200206190029_D.hdf.he2", "r") ; Read file for the second time to efficiently obtain lat and lon. 

  data_raw=eos_file->High_res_cloud ; read specific subset of data field

; Apply scale factor according to the field attribute
  data = data_raw * data_raw@Scale

  data@_FillValue = -9990.0 * data_raw@Scale

  data@units = data_raw@Unit
  
; Associate longitude and latitude
  data@lon2d=he2_file->Longitude_Swath1 ; associate longitude and latitude
  data@lat2d=he2_file->Latitude_Swath1

; open workstation
  xwks = gsn_open_wks("pdf","AMSR_E_L2_Ocean_V06_200206190029_D_High_res_cloud.ncl") ; open workstation

  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True ; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn = False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@lbOrientation = "vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0; white color for missing values

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  res@tiMainString = "AMSR_E_L2_Ocean_V06_200206190029_D.hdf" ; create title
  res@gsnLeftString = "Field name: High res cloud"
  res@gsnRightString = "Units: " + data@units

  plot=gsn_csm_contour_map_ce(xwks,data,res)

; cleaning up resources used
  delete(plot) 
  delete(res)
  delete(data)
  delete(data_raw)
  delete(he2_file)
  delete(eos_file)

end