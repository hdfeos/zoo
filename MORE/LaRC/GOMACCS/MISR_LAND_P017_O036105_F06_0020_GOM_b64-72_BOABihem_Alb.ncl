;This example code illustrates how to access and visualize LaRC_GOMACCS Grid in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 4-D grid file data field at various levels.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.


begin
eos_file=addfile("MISR_LAND_P017_O036105_F06_0020_GOM_b64-72.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

data=eos_file->BOABihemAlb_RegParamsLnd(63,:,:,0) ; read specific subset of data field
; 
; In order to read the BOABihemAlb data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

data@lon2d=eos_file->GridLon_RegParamsLnd ; associate longitude and latitude
data@lat2d=eos_file->GridLat_RegParamsLnd ; here, since the GridLon/GridLat arrays are 1-D, we use lon2d instead of lon2d

data_1=eos_file->BOABihemAlb_RegParamsLnd(64,:,:,1) ; read specific subset of data field
data_1@lon2d=eos_file->GridLon_RegParamsLnd ; associate longitude and latitude
data_1@lat2d=eos_file->GridLat_RegParamsLnd


data_2=eos_file->BOABihemAlb_RegParamsLnd(65,:,:,2) ; read specific subset of data field
data_2@lon2d=eos_file->GridLon_RegParamsLnd ; associate longitude and latitude
data_2@lat2d=eos_file->GridLat_RegParamsLnd



data_3=eos_file->BOABihemAlb_RegParamsLnd(66,:,:,3) ; read specific subset of data field
data_3@lon2d=eos_file->GridLon_RegParamsLnd ; associate longitude and latitude
data_3@lat2d=eos_file->GridLat_RegParamsLnd









xwks=gsn_open_wks("pdf","MISR_LAND_P017_O036105_F06_0020_GOM_b64-72_BOABihemAlb") ; open workstation 

res=True ; plot mods desired
res@cnFillOn=True ; enable contour fill
res@cnLinesOn=False ; turn off contour lines
res@gsnSpreadColors=True ; use the entire color spectrum
res@cnFillMode="RasterFill" ; faster
res@lbLabelAutoStride=True ; ensure labels do not overlap
res@lbOrientation = "vertical" ; vertical labels
res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
res@cnMissingValFillColor=0; white color for missing values
res@gsnLeftStringFontHeightF=15 ; make text smaller
res@gsnCenterStringFontHeightF=15
res@gsnRightStringFontHeightF=15

;res@cnLevelSelectionMode="ManualLevels" ; preset range defined to ensure uniform color legend across all levels
;res@cnLevelSpacingF=2500 ; set interval
;res@cnMinLevelValF=20000 ; set min and max values
;res@cnMaxLevelValF=105000 ; 

gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

plot=new(4, "graphic") ; allocate plot

res@tiMainString="MISR_LAND_P017_O036105_F06_0020_GOM_b64-72.hdf" ; create title




res@gsnCenterString="BOABihemAlb at TIME=1, Height=72" ; create center text
plot(0)=gsn_csm_contour_map_ce(xwks,data,res) 

delete(res@tiMainString) ; delete title for subsequent plots


res@gsnCenterString="BOABihemAlb at TIME=2, Height=50"
plot(1)=gsn_csm_contour_map_ce(xwks,data_1,res) 

res@gsnCenterString="BOABihemAlb at TIME=4, Height=42"
plot(2)=gsn_csm_contour_map_ce(xwks,data_2,res) 

res@gsnCenterString="BOABihemAlb at TIME=5, Height=46"
plot(3)=gsn_csm_contour_map_ce(xwks,data_3,res) 




delete(plot) ; cleaning up resources used
delete(xwks)
delete(data)
delete(data_1)
delete(data_2)
delete(data_3)
delete(res)
delete(eos_file)
end






