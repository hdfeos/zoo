;This example code illustrates how to access and visualize HDF_EOS5 Aura OMI L3 Grid file in NCL. 
;If you have any questions, suggestions, comments on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("OMI-Aura_L3-OMTO3e_2005m1214_v002-2006m0929t143855.he5", "r") ; Read file. 
;To read HDF-EOS5 files, .he5 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

data=eos_file->ColumnAmountO3_OMI_Column_Amount_O3

xwks   = gsn_open_wks ("pdf","OMI-Aura_L3-OMTO3e_2005m1214_v002-2006m0929t143855_ColumnAmountO3.ncl")    ; open workstation
gsn_define_colormap(xwks,"amwg")

res=True
res@gsnMaximize=True   ;make plot large
res@gsnPaperOrientation = "portrait"    ;force portrait orientation
res@gsnSpreadColors=True    ; use the entire color spectrum
res@tiMainString = "OMI-Aura_L3-OMTO3e_2005m1214_v002-2006m0929t143855_ColumnAmountO3"
res@cnFillOn=True   ;enable contour fill
res@cnLinesOn=False   ;turn off contour line
res@cnLineLabelsOn =  False    ;turn off contour line labels
res@lbOrientation="vertical" ; vertical labels
res@cnFillMode="RasterFill"   ;faster
res@lbLabelAutoStride= True

plot=gsn_csm_contour_map(xwks,data,res)
delete(plot)
delete(data)
delete(res)
delete(eos_file)
end
