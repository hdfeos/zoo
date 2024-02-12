;This example code illustrates how to access and visualize GESDISC_AIRS Swath in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).



load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 4-D swath file data field at various levels.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.


begin
eos_file=addfile("AIRS.2005.12.31.001.L2.RetSup.v5.0.14.0.G07289053644.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

data=eos_file->O3_ave_kern_L2_Support_atmospheric_surface_product(:,:,0,0) ; read specific subset of data field
; Here, because the variable O3Func is used as the variable in both the third and fourth arguments, 
; there are only 9 total subsets. In order to read the O3_ave_kern data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

data@lon2d=eos_file->Longitude_L2_Support_atmospheric_surface_product ; associate longitude and latitude
data@lat2d=eos_file->Latitude_L2_Support_atmospheric_surface_product
data@_FillValue= -9999 

data_1=eos_file->O3_ave_kern_L2_Support_atmospheric_surface_product(:,:,1,1) ; read specific subset of data field
data_1@lon2d=eos_file->Longitude_L2_Support_atmospheric_surface_product ; associate longitude and latitude
data_1@lat2d=eos_file->Latitude_L2_Support_atmospheric_surface_product
data_1@_FillValue= -9999 

data_2=eos_file->O3_ave_kern_L2_Support_atmospheric_surface_product(:,:,2,2) ; read specific subset of data field
data_2@lon2d=eos_file->Longitude_L2_Support_atmospheric_surface_product ; associate longitude and latitude
data_2@lat2d=eos_file->Latitude_L2_Support_atmospheric_surface_product
data_2@_FillValue= -9999 

data_3=eos_file->O3_ave_kern_L2_Support_atmospheric_surface_product(:,:,3,3) ; read specific subset of data field
data_3@lon2d=eos_file->Longitude_L2_Support_atmospheric_surface_product ; associate longitude and latitude
data_3@lat2d=eos_file->Latitude_L2_Support_atmospheric_surface_product
data_3@_FillValue= -9999 

data_4=eos_file->O3_ave_kern_L2_Support_atmospheric_surface_product(:,:,4,4) ; read specific subset of data field
data_4@lon2d=eos_file->Longitude_L2_Support_atmospheric_surface_product ; associate longitude and latitude
data_4@lat2d=eos_file->Latitude_L2_Support_atmospheric_surface_product
data_4@_FillValue= -9999 

data_5=eos_file->O3_ave_kern_L2_Support_atmospheric_surface_product(:,:,5,5) ; read specific subset of data field
data_5@lon2d=eos_file->Longitude_L2_Support_atmospheric_surface_product ; associate longitude and latitude
data_5@lat2d=eos_file->Latitude_L2_Support_atmospheric_surface_product
data_5@_FillValue= -9999 

data_6=eos_file->O3_ave_kern_L2_Support_atmospheric_surface_product(:,:,6,6) ; read specific subset of data field
data_6@lon2d=eos_file->Longitude_L2_Support_atmospheric_surface_product ; associate longitude and latitude
data_6@lat2d=eos_file->Latitude_L2_Support_atmospheric_surface_product
data_6@_FillValue= -9999 

data_7=eos_file->O3_ave_kern_L2_Support_atmospheric_surface_product(:,:,7,7) ; read specific subset of data field
data_7@lon2d=eos_file->Longitude_L2_Support_atmospheric_surface_product ; associate longitude and latitude
data_7@lat2d=eos_file->Latitude_L2_Support_atmospheric_surface_product
data_7@_FillValue= -9999 

data_8=eos_file->O3_ave_kern_L2_Support_atmospheric_surface_product(:,:,8,8) ; read specific subset of data field
data_8@lon2d=eos_file->Longitude_L2_Support_atmospheric_surface_product ; associate longitude and latitude
data_8@lat2d=eos_file->Latitude_L2_Support_atmospheric_surface_product
data_8@_FillValue= -9999 




xwks=gsn_open_wks("pdf","AIRS.2005.12.31.001.L2.RetSup.v5.0.14.0.G07289053644_O3_ave_kern") ; open workstation 

res=True ; plot mods desired
res@cnFillOn=True ; enable contour fill
res@cnLinesOn=False ; turn off contour lines
res@gsnSpreadColors=True ; use the entire color spectrum
res@cnFillMode="RasterFill" ; faster
res@lbLabelAutoStride=True ; ensure labels do not overlap
res@lbOrientation = "vertical" ; vertical labels
res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
res@cnMissingValFillColor=0; white color for missing values

res@mpMinLatF=60 ; only plot regions above 60 degrees latitude

res@cnLevelSelectionMode="ManualLevels" ; preset range defined to ensure uniform color legend across all levels
res@cnLevelSpacingF=.05 ; set interval
res@cnMinLevelValF=0 ; set min and max values
res@cnMaxLevelValF=.45 ; 

gsn_define_colormap(xwks,"amwg") ; define colormap

plot=new(9, "graphic") ; allocate plot
res@gsnPolar   = "NH" ; set polar plot to northern hemisphere

res@tiMainString="AIRS.2005.12.31.001.L2.RetSup.v5.0.14.0.G07289053644.hdf" ; create title
res@gsnCenterString="O3_ave_kern at O3Func=0, O3Func=0" ; create center text
plot(0)=gsn_csm_contour_map_polar(xwks,data,res) ; create plot

delete(res@tiMainString) ; delete title for subsequent plots

res@gsnCenterString="O3_ave_kern at O3Func=1, O3Func=1"
plot(1)=gsn_csm_contour_map_polar(xwks,data_1,res) 

res@gsnCenterString="O3_ave_kern at O3Func=2, O3Func=2"
plot(2)=gsn_csm_contour_map_polar(xwks,data_2,res) 

res@gsnCenterString="O3_ave_kern at O3Func=3, O3Func=3"
plot(3)=gsn_csm_contour_map_polar(xwks,data_3,res) 

res@gsnCenterString="O3_ave_kern at O3Func=4, O3Func=4"
plot(4)=gsn_csm_contour_map_polar(xwks,data_4,res)

res@gsnCenterString="O3_ave_kern at O3Func=5, O3Func=5"
plot(5)=gsn_csm_contour_map_polar(xwks,data_5,res) 
 
res@gsnCenterString="O3_ave_kern at O3Func=6, O3Func=6"
plot(6)=gsn_csm_contour_map_polar(xwks,data_6,res) 

res@gsnCenterString="O3_ave_kern at O3Func=7, O3Func=7"
plot(7)=gsn_csm_contour_map_polar(xwks,data_7,res) 

res@gsnCenterString="O3_ave_kern at O3Func=8, O3Func=8"
plot(8)=gsn_csm_contour_map_polar(xwks,data_8,res) 


delete(plot) ; cleaning up resources used
delete(data)
delete(data_1)
delete(data_2)
delete(data_3)
delete(data_4)
delete(data_5)
delete(data_6)
delete(data_7)
delete(data_8)
delete(res)
delete(eos_file)
end



