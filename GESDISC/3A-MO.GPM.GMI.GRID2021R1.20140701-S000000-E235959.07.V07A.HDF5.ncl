;
;   This example code illustrates how to access and visualize GESDISC GPM
; L3 HDF5 file in NCL. 
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
; $ncl 3A-MO.GPM.GMI.GRID2021R1.20140701-S000000-E235959.07.V07A.HDF5.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2024-07-29

begin
  file_name = "3A-MO.GPM.GMI.GRID2021R1.20140701-S000000-E235959.07.V07A.HDF5"
  h5_file = addfile(file_name, "r") 
;  print(h5_file)

  g = h5_file=>/Grid
  data_raw = g->cloudWater(0,:,:)
  data = transpose(data_raw)

  data@long_name = "/Grid/cloudWater"
  data@units = data_raw@units
  data@_FillValue = data_raw@_FillValue

  wks = gsn_open_wks("png", file_name+".ncl")
  res = True
  res@gsnMaximize = True
  res@gsnSpreadColors = True
  res@cnFillOn = True
  res@cnLinesOn = False
  res@cnLineLabelsOn =  False
  res@cnFillMode = "RasterFill"
  res@lbLabelAutoStride = True
  res@lbOrientation = "vertical"
  res@trGridType = "TriangularMesh" 
  res@tiMainString = file_name
  res@gsnLeftStringFontHeightF = 12
  res@gsnRightStringFontHeightF = 12
  plot = gsn_csm_contour_map(wks,data,res)
end

