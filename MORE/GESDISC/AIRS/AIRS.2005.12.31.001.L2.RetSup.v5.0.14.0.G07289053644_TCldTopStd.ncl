;This example code illustrates how to access and visualize GESDISC_AIRS Swath in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).



load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 3-D swath file data field at various levels.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.


begin
eos_file=addfile("AIRS.2005.12.31.001.L2.RetSup.v5.0.14.0.G07289053644.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

data=eos_file->TCldTopStd_L2_Support_atmospheric_surface_product(:,:,0) ; read specific subset of data field
; In order to read the TCldTopStd data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

data@lon2d=eos_file->Longitude_L2_Support_atmospheric_surface_product ; associate longitude and latitude
data@lat2d=eos_file->Latitude_L2_Support_atmospheric_surface_product
data@_FillValue= -9999 

data_1=eos_file->TCldTopStd_L2_Support_atmospheric_surface_product(:,:,1) ; read specific subset of data field
data_1@lon2d=eos_file->Longitude_L2_Support_atmospheric_surface_product ; associate longitude and latitude
data_1@lat2d=eos_file->Latitude_L2_Support_atmospheric_surface_product
data_1@_FillValue= -9999 


xwks=gsn_open_wks("pdf","AIRS.2005.12.31.001.L2.RetSup.v5.0.14.0.G07289053644_TCldTopStd") ; open workstation 

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
res@cnLevelSpacingF=5 ; set interval
res@cnMinLevelValF=200 ; set min and max values
res@cnMaxLevelValF=270 ; 

gsn_define_colormap(xwks,"amwg") ; define colormap

plot=new(2, "graphic") ; allocate plot
res@gsnPolar   = "NH" ; set polar plot to northern hemisphere

res@tiMainString="AIRS.2005.12.31.001.L2.RetSup.v5.0.14.0.G07289053644.hdf" ; create title
res@gsnCenterString="TCldTopStd at Cloud=0" ; create center text
plot(0)=gsn_csm_contour_map_polar(xwks,data,res) ; create plot

delete(res@tiMainString) ; delete title for subsequent plots

res@gsnCenterString="TCldTopStd at Cloud=1"
plot(1)=gsn_csm_contour_map_polar(xwks,data_1,res) 

delete(plot) ; cleaning up resources used
delete(data)
delete(data_1)
delete(res)
delete(eos_file)
end


