;
;  This example code illustrates how to access and visualize LaRC TES L3 CH4
; HDF-EOS5 Grid file in NCL.
;
;  If you have any questions, suggestions, comments on this example, please use
; the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage:save this script and run 
;
; $ncl TES-Aura_L3-CH4_r0000033028_C01_F01_11.he5.ncl
;
; Tested under: NCL 6.4.0
; Last updated: 2018-09-19

begin
  file_name = "TES-Aura_L3-CH4_r0000033028_C01_F01_11.he5"
  eos_file=addfile(file_name, "r") ; Read file. 

  data=eos_file->SurfacePressure_NadirGrid
  printVarSummary(data);
  xwks   = gsn_open_wks("png", file_name+".ncl")    ; open workstation
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

  res=True
  res@gsnMaximize=True   ;make plot large
  res@gsnPaperOrientation = "portrait"    ;force portrait orientation
  res@gsnSpreadColors=True    ; use the entire color spectrum
  res@cnFillOn=True   ;enable contour fill
  res@cnLinesOn=False   ;turn off contour line
  res@cnLineLabelsOn =  False    ;turn off contour line labels
  res@cnFillMode="RasterFill"   ;faster
  res@lbLabelAutoStride= True
  res@lbOrientation        = "Vertical"

  res@tiMainString = file_name
  plot=gsn_csm_contour_map(xwks,data,res)
end
