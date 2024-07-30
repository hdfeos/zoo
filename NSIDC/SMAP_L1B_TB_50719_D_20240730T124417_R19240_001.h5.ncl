;
;   This example code illustrates how to access and visualize NSIDC SMAP
; L1B HDF5 file in NCL. 
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
; $ncl SMAP_L1B_TB_50719_D_20240730T124417_R19240_001.h5.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2024-07-30


begin
  file_name = "SMAP_L1B_TB_50719_D_20240730T124417_R19240_001.h5"
  h5_file = addfile(file_name, "r") 
;  print(h5_file)

  data_raw = h5_file->tb_h
  data = where(data_raw.gt.data_raw@valid_min .and. data_raw.lt.data_raw@valid_max, data_raw, data_raw@_FillValue)
  data@lat2d = h5_file->tb_lat
  data@lon2d = h5_file->tb_lon
  data@long_name = data_raw@long_name
  data@units = data_raw@units
  
  wks = gsn_open_wks("png", file_name+".ncl")
  
  res = True
  res@cnFillMode = "RasterFill"
  res@cnFillOn = True
  res@cnLineLabelsOn = False  
  res@cnLinesOn = False
  res@gsnLeftStringFontHeightF = 12
  res@gsnRightStringFontHeightF = 12
  res@gsnMaximize = True
  res@gsnSpreadColors = True
  res@lbLabelAutoStride = True
  res@lbOrientation = "vertical"
  res@trGridType = "TriangularMesh" 
  res@tiMainString = file_name
  
  plot=gsn_csm_contour_map(wks,data,res)
end


