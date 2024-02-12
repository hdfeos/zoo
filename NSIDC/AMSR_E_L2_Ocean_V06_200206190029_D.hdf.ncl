;
;  This example code illustrates how to access and visualize NSIDC AMSR_E L2
; HDF-EOS2 Swath file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please use
; the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.4.0
; Last updated: 2018-09-24
begin
; Read file as HDF4 file.
  file_name = "AMSR_E_L2_Ocean_V06_200206190029_D.hdf"
  eos_file = addfile(file_name, "r")
; Read file as HDF-EOS2 file for the second time to efficiently obtain lat and lon.
  he2_file = addfile(file_name+".he2", "r")

  data_raw=eos_file->High_res_cloud ; read specific subset of data field

; Apply scale factor according to the field attribute
  data = data_raw * data_raw@Scale

  data@_FillValue = -9990.0 * data_raw@Scale

  data@units = data_raw@Unit
  
; Associate longitude and latitude
  data@lon2d=he2_file->Longitude_Swath1
  data@lat2d=he2_file->Latitude_Swath1


  xwks = gsn_open_wks("png", file_name+".ncl")
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

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  res@tiMainString = file_name
  data@long_name = "High res cloud"

  plot=gsn_csm_contour_map_ce(xwks,data,res)
end