;
; This example code illustrates how to access and visualize LaRC ASDC MOPITT 
; version 7 HDF-EOS5 Grid file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.1.2
; Last updated: 2014-1-17

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  file_name= "MOP03T-20131129-L3V4.2.1.he5"
  eos_file=addfile(file_name, "r") ; Read file. 

  print(eos_file)

  data=eos_file->RetrievedSurfaceTemperatureDay_MOP03

  ; Data is transposed.
  dataT=transpose(data)

  xwks = gsn_open_wks("png", file_name+".ncl") ; open workstation
  gsn_define_colormap(xwks,"amwg")

  res=True
  res@gsnMaximize=True   ;make plot large
  res@gsnPaperOrientation = "portrait"    ;force portrait orientation
  res@gsnSpreadColors=True    ; use the entire color spectrum
  res@tiMainString = file_name
  res@cnFillOn=True   ;enable contour fill
  res@cnLinesOn=False   ;turn off contour line
  res@cnLineLabelsOn =  False    ;turn off contour line labels
  res@lbOrientation="vertical" ; vertical labels
  res@cnFillMode="RasterFill"   ;faster
  res@lbLabelAutoStride= True

  ; Data is stored upside-down.
  res@sfYArray = eos_file->Latitude_MOP03

  plot=gsn_csm_contour_map(xwks,dataT,res)
  delete(plot)
  delete(data)
  delete(res)
  delete(eos_file)
end
