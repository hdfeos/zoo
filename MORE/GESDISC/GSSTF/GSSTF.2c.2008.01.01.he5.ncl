;
;  This example code illustrates how to access and visualize MEaSUREs GSSTF
; HDF-EOS5 Grid file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.6.2
; Last updated: 2021-02-15

begin
  file_name = "GSSTF.2c.2008.01.01.he5"
  eos_file = addfile(file_name, "r") ; Read file. 

; List all variables in the HDF-EOS file.
;  print(eos_file)
  data1=eos_file->Qair_SET1

; Long name attribute has '~' character, a function code character in NCL.
  data1@long_name = str_sub_str(data1@long_name, "~", "~~")

  xwks = gsn_open_wks ("png", file_name+".ncl")
  gsn_define_colormap(xwks, "amwg")

  res=True
  res@gsnMaximize=True
  res@gsnSpreadColors=True
  res@tiMainString=file_name
  res@cnFillOn=True             ; enable contour fill
  res@cnLinesOn=False           ; turn off contour line
  res@cnLineLabelsOn= False   ; turn off contour line labels
  res@lbOrientation="vertical"  ; vertical labels
  res@cnFillMode="RasterFill"   ; faster
  res@lbLabelAutoStride=True

  plot=gsn_csm_contour_map(xwks,data1,res)
end
