;
;  This example code illustrates how to access and visualize MEaSUREs GSSTFYC
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
; Last updated: 2021-02-11

begin
  file_name = "GSSTFYC.3.Year.1988_2008.he5"
  eos_file = addfile(file_name, "r") ; Read file. 

; List all variables in the HDF-EOS file.
;  print(eos_file)
  data1=eos_file->SST_NCEP
  data1@long_name = data1@LongName

  xwks   = gsn_open_wks ("png", file_name+".ncl")    ; open workstation
  gsn_define_colormap(xwks,"amwg")

  res=True
  res@gsnMaximize=True   ;make plot large
  res@gsnSpreadColors=True    ; use the entire color spectrum
  res@tiMainString = file_name
  res@cnFillOn=True   ;enable contour fill
  res@cnLinesOn=False   ;turn off contour line
  res@cnLineLabelsOn =  False    ;turn off contour line labels
  res@lbOrientation="vertical" ; vertical labels
  res@cnFillMode="RasterFill"   ;faster
  res@lbLabelAutoStride= True

  plot=gsn_csm_contour_map(xwks,data1,res)
end
