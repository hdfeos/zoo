;
;  This example code illustrates how to access and visualize GES DISC OMI
;  Level 2 HDF-EOS5 file in NCL. 
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
; $ncl OMI-Aura_L2-OMNO2_2008m0720t2016-o21357_v003-2016m0820t102252.he5.ncl
; Tested under: NCL 6.4.0
; Last updated: 2018-01-16

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; Read file.   
file_name = "OMI-Aura_L2-OMNO2_2008m0720t2016-o21357_v003-2016m0820t102252.he5"
eos_file=addfile(file_name, "r") 
data_unscaled=eos_file->CloudFraction_ColumnAmountNO2

; Check attributes.
printVarSummary(data_unscaled)

scale_factor=data_unscaled@ScaleFactor
add_offset=data_unscaled@Offset

; Multiply scale and add offset. The equation is scale*(data-offset).
data=scale_factor*(data_unscaled-add_offset)

data@lat2d=eos_file->Latitude_ColumnAmountNO2
data@lon2d=eos_file->Longitude_ColumnAmountNO2

; Reuse the original attributes for nice plot.
data@long_name = data_unscaled@Title
data@units = data_unscaled@Units

xwks   = gsn_open_wks ("png",file_name + ".ncl")    ; open workstation
gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

res=True
res@gsnMaximize=True   ;make plot large
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
