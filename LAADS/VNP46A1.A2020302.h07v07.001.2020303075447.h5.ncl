;
;  This example code illustrates how to access and visualize GES DISC MERRA
; L3 HDF-EOS5 Grid file in NCL.
;
;  If you have any questions, suggestions, comments  on this example, please
; use the HDF-EOS Forum (http://hdfeos.org/forums).
;
;  If you would like to see an example of any other NASA HDF/HDF-EOS data
; product that is not listed in the HDF-EOS Comprehensive Examples page
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Usage:save this script and run
;
; $ncl VNP46A1.A2020302.h07v07.001.2020303075447.h5.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2020-11-03


begin
  file_name = "VNP46A1.A2020302.h07v07.001.2020303075447.h5"
  
  ; Read as an HDF-EOS5 file.
  eos_file=addfile(file_name+".he5", "r")
  ; print(eos_file)

  ; Read dataset.
  data=short2flt(eos_file->BrightnessTemperature_M15_VNP_Grid_DNB)

  xwks=gsn_open_wks("png", file_name+".ncl")

  res=True
  res@cnFillOn=True
  res@cnLinesOn=False
  res@gsnMaximize=True
  res@gsnSpreadColors=True
  res@cnFillMode="RasterFill"
  res@lbLabelAutoStride=True
  res@lbOrientation="vertical"
  res@gsnAddCyclic=False    
  res@gsnLeftStringFontHeightF=10
  res@gsnRightStringFontHeightF=10
  res@tiMainString=file_name
  res@trGridType="TriangularMesh"

  
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")
  plot=gsn_csm_contour_map_ce(xwks, data, res) 
end
