;
;   This example code illustrates how to access and visualize NSIDC SMAP
; L1A HDF5 file in NCL. 
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
; $ncl SMAP_L1A_RADIOMETER_30031_A_20200914T223611_R17000_001.h5.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2020-09-15

; This is the main program.
begin
  file_name = "SMAP_L1A_RADIOMETER_30031_A_20200914T223611_R17000_001.h5"

; Read file as an HDF5 file. 
  h5_file = addfile(file_name, "r") 
;  print(h5_file)
  data_raw = h5_file->moments16_right_ascension
  data = where(data_raw.gt.data_raw@valid_min .and. data_raw.lt.data_raw@valid_max, data_raw, data_raw@_FillValue)
  data@lat2d = h5_file->moments16_lat
  data@lon2d = h5_file->moments16_lon
  data@long_name = data_raw@long_name
  data@units = data_raw@units
  
  wks = gsn_open_wks("png", file_name+".ncl") ; open workstation
  res=True
  res@gsnMaximize=True   ;make plot large
  res@gsnPaperOrientation = "portrait"    ;force portrait orientation
  res@gsnSpreadColors=True    ; use the entire color spectrum
  res@cnFillOn=True   ;enable contour fill
  res@cnLinesOn=False   ;turn off contour line
  res@cnLineLabelsOn =  False    ;turn off contour line labels
  res@cnFillMode="RasterFill"   ;faster
  res@lbLabelAutoStride= True
  res@lbOrientation="vertical" ;vertical labels
  res@trGridType = "TriangularMesh" 
  res@tiMainString = file_name
  res@gsnLeftStringFontHeightF = 12 ; make font smaller 
  res@gsnRightStringFontHeightF = 12 ; make font smaller   
  plot=gsn_csm_contour_map(wks,data,res)
end

