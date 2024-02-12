;This example code illustrates how to access and visualize HDF_EOS5 file in NCL. 
;If you have any questions, suggestions, comments on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; This is an example of a 2-D grid file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
file_name = "OMI-Aura_L2-OMNO2_2008m0720t2016-o21357_v003-2008m0721t101450.he5"
eos_file=addfile(file_name, "r") ; Read file. 
;To read HDF-EOS5 files, .he5 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

data_unscaled=eos_file->CloudFraction_ColumnAmountNO2

; Check attributes.
printVarSummary(data_unscaled)

scale_factor=data_unscaled@ScaleFactor
add_offset=data_unscaled@Offset

; Multiple scale and add offset. The equation is scale*(data-offset).
data=scale_factor*(data_unscaled-add_offset)

data@lat2d=eos_file->Latitude_ColumnAmountNO2
data@lon2d=eos_file->Longitude_ColumnAmountNO2

; Reuse the original attributes for nice plot.
data@long_name = data_unscaled@Title
data@units = data_unscaled@Units

xwks   = gsn_open_wks ("pdf","OMI-Aura_L2-OMNO2_2008m0720t2016-o21357_v003-2008m0721t101450_CloudFraction.ncl")    ; open workstation
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
res@lbOrientation="vertical" ;vertical labels
res@tiMainString = file_name
plot=gsn_csm_contour_map(xwks,data,res)

delete(plot)
delete(data)
delete(res)
delete(eos_file)
end
