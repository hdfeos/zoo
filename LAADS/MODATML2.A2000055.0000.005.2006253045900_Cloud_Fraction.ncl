;This example code illustrates how to access and visualize LAADS_MOD swath file in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.


begin
eos_file=addfile("MODATML2.A2000055.0000.005.2006253045900.hdf", "r") ; Read file. 

data_signed=eos_file->Cloud_Fraction ; read data field

; data_signed@_FillValue=data_signed@_FillValue ; _FillValue=127, given from the attributes of Cloud_Fraction

scale=data_signed@scale_factor; scale_factor=0.009999999776482582, given from the attributes of Cloud_Fraction

offset=data_signed@add_offset ; add_offset=0.0, given from the attributes of Cloud_Fraction

data = ( data_signed - offset ) * scale

data@lat2d=eos_file->Latitude
data@lon2d=eos_file->Longitude

xwks=gsn_open_wks("pdf","MODATML2.A2000055.0000.005.2006253045900") ; open workstation 

setvalues NhlGetWorkspaceObjectId() ; make maximum filesize larger
"wsMaximumSize" : 200000000
end setvalues

res=True ; plot mods desired
res@cnFillOn=True ; enable contour fill
res@cnLinesOn=False ; turn off contour lines
res@gsnSpreadColors=True ; use the entire color spectrum
res@cnFillMode="RasterFill" ; faster
res@lbLabelAutoStride=True ; ensure labels do not overlap
res@lbOrientation = "vertical" ; vertical labels
res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
res@cnMissingValFillColor=0; white color for missing values

gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

res@tiMainString =  "MODATML2.A2000055.0000.005.2006253045900.hdf"
res@gsnLeftString = "FIELD NAME: Cloud_Fraction"
res@gsnRightString = "UNITS: " + data_signed@units

plot=gsn_csm_contour_map_ce(xwks,data,res) 

delete(plot) ; cleaning up resources used
delete(xwks)
delete(data)
delete(res)
delete(eos_file)
end