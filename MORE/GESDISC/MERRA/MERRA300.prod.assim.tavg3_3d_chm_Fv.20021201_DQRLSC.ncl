;This example code illustrates how to access and visualize GESDISC_MERRA in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 3-D grid file data field at various levels.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.


begin
eos_file=addfile("MERRA300.prod.assim.tavg3_3d_chm_Fv.20021201.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

data=eos_file->DQRLSC_EOSGRID(1,:,:) ; read specific subset of data field
; 
; In order to read the T data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

data@lon1d=eos_file->XDim_EOSGRID ; associate longitude and latitude
data@lat1d=eos_file->YDim_EOSGRID ; here, since the XDim/YDim arrays are 1-D, we use lon1d instead of lon2d
data@units="kg/kg/s"
data@long_name="Precipitation production rate"

data_1=eos_file->DQRLSC_EOSGRID(2,:,:) ; read specific subset of data field
data_1@lon1d=eos_file->XDim_EOSGRID ; associate longitude and latitude
data_1@lat1d=eos_file->YDim_EOSGRID
data_1@units="kg/kg/s"
data_1@long_name="Precipitation production rate"


data_2=eos_file->DQRLSC_EOSGRID(4,:,:) ; read specific subset of data field
data_2@lon1d=eos_file->XDim_EOSGRID ; associate longitude and latitude
data_2@lat1d=eos_file->YDim_EOSGRID
data_2@units="kg/kg/s"
data_2@long_name="Precipitation production rate"


data_3=eos_file->DQRLSC_EOSGRID(5,:,:) ; read specific subset of data field
data_3@lon1d=eos_file->XDim_EOSGRID ; associate longitude and latitude
data_3@lat1d=eos_file->YDim_EOSGRID
data_3@units="kg/kg/s"
data_3@long_name="Precipitation production rate"


data_4=eos_file->DQRLSC_EOSGRID(7,:,:) ; read specific subset of data field
data_4@lon1d=eos_file->XDim_EOSGRID ; associate longitude and latitude
data_4@lat1d=eos_file->YDim_EOSGRID
data_4@units="kg/kg/s"
data_4@long_name="Precipitation production rate"






xwks=gsn_open_wks("pdf","MERRA300.prod.assim.tavg3_3d_chm_Fv.20021201_DQRLSC") ; open workstation 

res=True ; plot mods desired
res@cnFillOn=True ; enable contour fill
res@cnLinesOn=False ; turn off contour lines
res@gsnSpreadColors=True ; use the entire color spectrum
res@cnFillMode="RasterFill" ; faster
res@lbLabelAutoStride=True ; ensure labels do not overlap
res@lbOrientation = "vertical" ; vertical labels
res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
res@cnMissingValFillColor=0; white color for missing values
res@gsnLeftStringFontHeightF=10 ; make text smaller
res@gsnCenterStringFontHeightF=10
res@gsnRightStringFontHeightF=10

res@cnLevelSelectionMode="ManualLevels" ; preset range defined to ensure uniform color legend across all levels
res@cnLevelSpacingF=.0001 ; set interval
res@cnMinLevelValF=.0001 ; set min and max values
res@cnMaxLevelValF=.002 ; 

gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

plot=new(5, "graphic") ; allocate plot

res@tiMainString="MERRA300.prod.assim.tavg3_3d_chm_Fv.20021201.hdf" ; create title




res@gsnCenterString="DQRLSC at TIME=1" ; create center text
plot(0)=gsn_csm_contour_map_ce(xwks,data,res) 

delete(res@tiMainString) ; delete title for subsequent plots


res@gsnCenterString="DQRLSC at TIME=2"
plot(1)=gsn_csm_contour_map_ce(xwks,data_1,res) 

res@gsnCenterString="DQRLSC at TIME=4"
plot(2)=gsn_csm_contour_map_ce(xwks,data_2,res) 

res@gsnCenterString="DQRLSC at TIME=5"
plot(3)=gsn_csm_contour_map_ce(xwks,data_3,res) 

res@gsnCenterString="DQRLSC at TIME=7"
plot(4)=gsn_csm_contour_map_ce(xwks,data_4,res)


delete(plot) ; cleaning up resources used
delete(xwks)
delete(data)
delete(data_1)
delete(data_2)
delete(data_3)
delete(data_4)
delete(res)
delete(eos_file)
end








