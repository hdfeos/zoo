;This example code illustrates how to access and visualize GESDISC_AIRS Swath in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).



load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 1-D swath file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.


begin
eos_file=addfile("AIRS.2005.12.31.L1B.Cal_Subset.v5.0.16.0.G08008000255.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.


topog=eos_file->topog_L1B_AIRS_Cal_Subset ; read data field
; In order to read the topog data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.



xwks=gsn_open_wks("pdf","AIRS.2005.12.31.L1B.Cal_Subset.v5.0.16.0.G08008000255_topog") ; open workstation

res=True ; plot mods desired
res@cnFillOn=True ; enable contour fill
res@cnLinesOn=False ; turn off contour lines
res@gsnSpreadColors=True ; use the entire color spectrum
res@cnFillMode="RasterFill" ; faster
res@lbLabelAutoStride=True ; ensure labels do not overlap
res@lbOrientation = "vertical" ; vertical labels
res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
res@cnMissingValFillColor=0; white color for missing values

res@sfXArray = eos_file->Longitude_L1B_AIRS_Cal_Subset ; associate 1d longitude and latitude 
res@sfYArray = eos_file->Latitude_L1B_AIRS_Cal_Subset


gsn_define_colormap(xwks,"amwg") ; define colormap

res@tiMainString="AIRS.2005.12.31.L1B.Cal_Subset.v5.0.16.0.G08008000255.hdf"
res@gsnCenterString="topog"
plot=gsn_csm_contour_map_ce(xwks,topog,res)

delete(plot) ; cleaning up used resources
delete(topog)
delete(res)
delete(eos_file)
end
