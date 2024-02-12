;
;  This example code illustrates how to access and visualize LaRC CERES 
; ES8 NPP FM5 HDF-EOS2 file in NCL. 
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
; $ncl CER_ES8_NPP-FM5_Edition2_203209.20220131.hdf.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2022-11-28

begin
  file_name = "CER_ES8_NPP-FM5_Edition2_203209.20220131.hdf";
  eos_file=addfile(file_name + ".he2", "r")
;  print(eos_file)

; Read data field.
  data=eos_file->CERES_LW_flux_at_TOA_CERES_ES8


  colat=eos_file->Colatitude_of_CERES_FOV_at_TOA_CERES_ES8
  lon=eos_file->Longitude_of_CERES_FOV_at_TOA_CERES_ES8
  
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
  res@trGridType = "TriangularMesh" ; lat/lon has fill values
   
  plot=gsn_csm_contour_map(xwks,data,res)
  
end
