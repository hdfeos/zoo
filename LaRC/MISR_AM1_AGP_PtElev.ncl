;This example code illustrates how to access and visualize LaRC_MISR Grid file in NCL. 
;If you have any questions, suggestions, comments on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 3-D grid file data field at various levels with 3-D geolocation fields.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("MISR_AM1_AGP_P001_F01_24.hdf.he2", "r") ; Read file. 

data=eos_file->PtElev_Standard(0,:,:) ; read specific subset of data field


data@lat2d=eos_file->GeoLatitude_Standard(0,:,:); associate longitude and latitude
data@lon2d=eos_file->GeoLongitude_Standard(0,:,:); 



data_1=eos_file->PtElev_Standard(26,:,:)
data_1@lat2d=eos_file->GeoLatitude_Standard(26,:,:);
data_1@lon2d=eos_file->GeoLongitude_Standard(26,:,:); 


data_2=eos_file->PtElev_Standard(35,:,:)
data_2@lat2d=eos_file->GeoLatitude_Standard(35,:,:); 
data_2@lon2d=eos_file->GeoLongitude_Standard(35,:,:); 

data_3=eos_file->PtElev_Standard(99,:,:)
data_3@lat2d=eos_file->GeoLatitude_Standard(99,:,:); 
data_3@lon2d=eos_file->GeoLongitude_Standard(99,:,:); 



xwks=gsn_open_wks("pdf","MISR_AM1_AGP_P001_F01_24_PtElev") ; open workstation

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
res@lbLabelAutoStride = True ; ensure no label overlap
res@gsnLeftStringFontHeightF=10 ; make text smaller
res@gsnCenterStringFontHeightF=10
res@gsnRightStringFontHeightF=10

res@mpLimitMode         = "LatLon"
res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
res@mpMaxLatF	= max(data@lat2d) ; 
res@mpMinLonF	= min(data@lon2d) ;
res@mpMaxLonF	= max(data@lon2d) ;

res@cnLevelSelectionMode="ManualLevels" ; preset range defined to ensure uniform color legend across all levels
;res@cnLevelSpacingF=25 ; set interval
;res@cnMinLevelValF=-225 ; set min and max values
;res@cnMaxLevelValF=125 ;

gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap


res@tiMainString="MISR_AM1_AGP_P001_F01_24.hdf" ; create title
plot=new(4, "graphic") ; allocate plot
res@gsnCenterString="PtElev at SOMBlockDim=0" ; create center text
plot(0)=gsn_csm_contour_map_ce(xwks,data,res) ; 
delete(res@tiMainString) ; delete title for subsequent plots

res@mpMinLatF	= min(data_1@lat2d) ; Set new limits to new coordinates
res@mpMaxLatF	= max(data_1@lat2d) ; 
res@mpMinLonF	= min(data_1@lon2d) ;
res@mpMaxLonF	= max(data_1@lon2d) ;

res@gsnCenterString="PtElev at SOMBlockDim=26" ; create center text
plot(1)=gsn_csm_contour_map_ce(xwks,data_1,res) ; 

res@mpMinLatF	= min(data_2@lat2d) ; 
res@mpMaxLatF	= max(data_2@lat2d) ; 
res@mpMinLonF	= min(data_2@lon2d) ;
res@mpMaxLonF	= max(data_2@lon2d) ;

res@gsnCenterString="PtElev at SOMBlockDim=35"
plot(2)=gsn_csm_contour_map_ce(xwks,data_2,res)

res@mpMinLatF	= min(data_3@lat2d) ; 
res@mpMaxLatF	= max(data_3@lat2d) ; 
res@mpMinLonF	= min(data_3@lon2d) ;
res@mpMaxLonF	= max(data_3@lon2d) ;

res@gsnCenterString="PtElev at SOMBlockDim=99"
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




