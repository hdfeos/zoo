;
;   This example code illustrates how to access and visualize NSIDC SMAP
; L4 HDF5 file in NCL. 
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
; $ncl SMAP_L4_SM_gph_20200915T193000_Vv7032_001.h5.ncl
; 
; Tested under: NCL 6.6.2
; Last updated: 2024-07-30

begin
  file_name = "SMAP_L4_SM_gph_20200915T193000_Vv7032_001.h5"

; Read file as an HDF5 file. 
  h5_file = addfile(file_name, "r") 
;  print(h5_file)
  data_raw = h5_file->sm_profile
  data = where(data_raw.gt.data_raw@valid_min .and. data_raw.lt.data_raw@valid_max, data_raw, data_raw@_FillValue)
  data@lat2d = h5_file->cell_lat
  data@lon2d = h5_file->cell_lon
  data@long_name = data_raw@long_name
  data@units = data_raw@units
  
  wks = gsn_open_wks("png", file_name+".ncl")
  
  res = True
  res@gsnLeftStringFontHeightF = 12
  res@gsnRightStringFontHeightF = 12
  res@gsnMaximize = True
  res@gsnSpreadColors = True
  res@cnFillMode = "RasterFill"  
  res@cnFillOn = True
  res@cnLineLabelsOn = False  
  res@cnLinesOn = False
  res@lbLabelAutoStride = True
  res@lbOrientation = "vertical"
  res@tiMainString = file_name  
  res@trGridType = "TriangularMesh" 
  
  plot = gsn_csm_contour_map(wks,data,res)
end

