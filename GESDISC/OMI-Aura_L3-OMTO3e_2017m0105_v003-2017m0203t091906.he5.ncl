;
;   This example code illustrates how to access and visualize GES DISC OMI v3
; HDF-EOS5 Grid file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage:save this script and run
;
; $ncl OMI-Aura_L3-OMTO3e_2017m0105_v003-2017m0203t091906.he5.ncl
;
; Tested under: NCL 6.4.0
; Last updated: 2017-04-03

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; It is assumed users know how to obtain information such as _FillValue from 
; HDFView.
; For information about HDFView, please visit 
; https://support.hdfgroup.org/products/java/hdfview/


begin

  file_name="OMI-Aura_L3-OMTO3e_2017m0105_v003-2017m0203t091906.he5"

  eos_file=addfile(file_name, "r")  ; Read file. 
; To read HDF-EOS5 files, .he5 is appended to the argument. 
; For more information, consult section 4.3.2 of 
; http://hdfeos.org/software/ncl.php

  data=eos_file->ColumnAmountO3_OMI_Column_Amount_O3

  xwks=gsn_open_wks("png", file_name+".ncl")

  res=True
  res@cnFillOn=True
  res@gsnMaximize=True
  res@cnLinesOn=False
  res@cnLineLabelsOn=False
  res@gsnSpreadColors=True
  res@cnFillMode="RasterFill"
  res@lbOrientation="vertical"
  res@cnMissingValFillPattern=0
  res@cnMissingValFillColor=0

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  res@tiMainString=file_name
  plot=gsn_csm_contour_map_ce(xwks,data,res)

  delete(res@tiMainString)
  delete(plot)
  delete(data)
  delete(res)
  delete(eos_file)
end
