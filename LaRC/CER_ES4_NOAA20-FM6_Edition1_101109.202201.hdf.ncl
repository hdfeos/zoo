;
;  This example code illustrates how to access and visualize LaRC CERES 
; ES4 NOAA20 FM6 HDF-EOS2 file in NCL. 
;
;  If you have any questions, suggestions, comments  on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage:save this script and run 
;
; $ncl CER_ES4_NOAA20-FM6_Edition1_101109.202201.hdf.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2022-11-21

begin

  file_name = "CER_ES4_NOAA20-FM6_Edition1_101109.202201.hdf";
  eos_file = addfile(file_name + ".he2", "r")
  ;print(eos_file)

; Read data field.
  data = eos_file->$"Longwave flux"$

  colat = eos_file->Colatitude
  lon = eos_file->Longitude
  
  data@lat2d = 90 - colat
  data@lon2d = lon 

  xwks = gsn_open_wks("png", file_name+".ncl") 
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

  res = True
  
  res@cnFillOn = True
  res@cnLinesOn = False
  res@cnLineLabelsOn = False
  res@cnFillMode = "RasterFill"

  res@gsnMaximize = True
  res@gsnRightStringFontHeightF = 0.01
  res@gsnSpreadColors = True

  res@lbLabelAutoStride = True
  res@lbOrientation = "Vertical"

  res@tiMainString = file_name
  plot=gsn_csm_contour_map(xwks,data,res)
  
end
