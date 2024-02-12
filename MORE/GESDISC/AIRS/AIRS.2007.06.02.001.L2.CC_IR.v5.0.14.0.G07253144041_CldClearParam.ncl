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
eos_file=addfile("AIRS.2007.06.02.001.L2.CC_IR.v5.0.14.0.G07253144041.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

data=eos_file->CldClearParam_L2_Standard_cloud_cleared_radiance_product(:,:,0,0) ; read specific subset of data field
; In order to read the radiances data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

data@lon2d=eos_file->Longitude_L2_Standard_cloud_cleared_radiance_product ; associate longitude and latitude
data@lat2d=eos_file->Latitude_L2_Standard_cloud_cleared_radiance_product
data@_FillValue=-9999

data_1=eos_file->CldClearParam_L2_Standard_cloud_cleared_radiance_product(:,:,0,2) 
data_1@lon2d=eos_file->Longitude_L2_Standard_cloud_cleared_radiance_product 
data_1@lat2d=eos_file->Latitude_L2_Standard_cloud_cleared_radiance_product
data_1@_FillValue=-9999

data_2=eos_file->CldClearParam_L2_Standard_cloud_cleared_radiance_product(:,:,1,2) 
data_2@lon2d=eos_file->Longitude_L2_Standard_cloud_cleared_radiance_product 
data_2@lat2d=eos_file->Latitude_L2_Standard_cloud_cleared_radiance_product
data_2@_FillValue=-9999

data_3=eos_file->CldClearParam_L2_Standard_cloud_cleared_radiance_product(:,:,2,2) 
data_3@lon2d=eos_file->Longitude_L2_Standard_cloud_cleared_radiance_product 
data_3@lat2d=eos_file->Latitude_L2_Standard_cloud_cleared_radiance_product
data_3@_FillValue=-9999

xwks=gsn_open_wks("pdf","AIRS.2007.06.02.001.L2.CC_IR.v5.0.14.0.G07253144041_CldClearParam") ; open workstation

res=True ; plot mods desired
res@cnFillOn=True ; enable contour fill
res@gsnMaximize=True; make plot large
res@gsnPaperOrientation =	"portrait" ; force portrait orientation
res@cnLinesOn=False ; turn off contour lines
res@cnLineLabelsOn       =  False; turn off contour line labels
res@gsnSpreadColors=True ; use the entire color spectrum
res@cnFillMode="RasterFill" ; faster
res@lbOrientation="vertical" ; vertical labels
res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
res@cnMissingValFillColor=0; white color for missing values




res@cnLevelSelectionMode="ManualLevels" ; preset range defined to ensure uniform color legend across all levels
res@cnLevelSpacingF=.2 ; set interval
res@cnMinLevelValF=-2.4 ; set min and max values
res@cnMaxLevelValF=2 ;

gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

res@tiMainString="AIRS.2007.06.02.001.L2.CC_IR.v5.0.14.0.G07253144041.hdf" ; create title
plot=new(5, "graphic") ; allocate plot

res@gsnCenterString="CldClearParam at GeoTrack=0, GeoXTrack=0" ; create center text
plot(0)=gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first
delete(res@tiMainString) ; delete title for subsequent plots


res@mpLimitMode         = "LatLon"
res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
res@mpMaxLatF	= max(data@lat2d) ; 
res@mpMinLonF	= min(data@lon2d) ;
res@mpMaxLonF	= max(data@lon2d) ;

res@gsnCenterString="CldClearParam at GeoTrack=0, GeoXTrack=0" 
plot(1)=gsn_csm_contour_map_ce(xwks,data,res)
res@gsnCenterString="CldClearParam at GeoTrack=0, GeoXTrack=2"
plot(2)=gsn_csm_contour_map_ce(xwks,data_1,res)

res@gsnCenterString="CldClearParam at GeoTrack=1, GeoXTrack=2"
plot(3)=gsn_csm_contour_map_ce(xwks,data_2,res)

res@gsnCenterString="CldClearParam at GeoTrack=2, GeoXTrack=2"
plot(4)=gsn_csm_contour_map_ce(xwks,data_3,res)

delete(plot) ; cleaning up resources used
delete(data)
delete(data_1)
delete(data_2)
delete(data_3)
delete(res)

delete(eos_file)
end



