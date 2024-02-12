;This example code illustrates how to access and visualize GHRC file in NCL. 
;If you have any questions, suggestions, comments on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

hdf_file = addfile("LISOTD_HRAC_V2.2.hdf", "r")

flash = hdf_file->HRAC_COM_FR

flash@_FillValue=0.0
flash@_FillValue=-1.0

; Subset data
data = flash(:,:,0)


; This is a HDF dimension scale model,
; so I do not need to manually specify the lat and lon,
; just let NCL handle it.


xwks = gsn_open_wks("pdf","LISOTD_HRAC_V2.2_HRAC_COM_FR")


res=True                                ; plot mods desired
res@cnFillOn=True                       ; enable contour fill
res@cnLinesOn=False                     ; turn off contour lines
res@gsnSpreadColors=True                ; use the entire color spectrum
res@cnFillMode="RasterFill"             ; faster
res@lbLabelAutoStride=True              ; ensure labels do not overlap
res@lbOrientation = "vertical"          ; vertical labels
res@cnMissingValFillPattern = 0         ; missing value pattern is set to "SolidFill"
res@cnMissingValFillColor=0             ; white color for missing values


gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap


res@tiMainString="LISOTD_HRAC_V2.2.hdf" ; create title from file attribute
res@gsnLeftString = "FIELD NAME: ~C~" + data@long_name
res@gsnRightString = "UNITS: ~C~" + data@units


plot=gsn_csm_contour_map_ce(xwks,data,res) 


delete(plot) ; cleaning up resources used
delete(xwks)
delete(data)
delete(res)
delete(hdf_file)
end