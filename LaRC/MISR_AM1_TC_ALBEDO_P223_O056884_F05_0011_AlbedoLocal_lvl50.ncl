;This example code illustrates how to access and visualize LaRC_MISR Grid file in NCL. 
;If you have any questions, suggestions, comments on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums).
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
eos_file=addfile("MISR_AM1_TC_ALBEDO_P223_O056884_F05_0011.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

data=eos_file->AlbedoLocal_ReflectingLevelParameters_2_2_km (50,:,:,0); read specific subset of data field
; In order to read the data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

dimsize=dimsizes(data)
nlon=dimsize(0)  ;
nlat=dimsize(1)  ;

; The file contains SOM projection. We need to use eos2dump to generate lat and lon
; For information on how to obtain the lat/lon data, check this URL http://hdfeos.org/zoo/note_non_geographic.php

data@lat2d=asciiread("lat_MISR_TC_ALBEDO_P223_F05_lvl50.output",(/nlon,nlat/),"float")
data@lon2d=asciiread("lon_MISR_TC_ALBEDO_P223_F05_lvl50.output",(/nlon,nlat/),"float")

xwks=gsn_open_wks("pdf","MISR_AM1_TC_ALBEDO_P223_O056884_F05_0011_AlbedoLocal_lvl50") ; open workstation

res=True ; plot mods desired
res@cnFillOn=True ; enable contour fill
res@gsnMaximize=True; make plot large
res@gsnPaperOrientation ="portrait" 
res@cnLinesOn=False ; turn off contour lines
res@cnLineLabelsOn = False; turn off contour line labels
res@gsnSpreadColors=True ; use the entire color spectrum
res@cnFillMode="RasterFill" ; faster
res@lbOrientation="vertical" ; vertical labels
res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
res@cnMissingValFillColor=0; white color for missing values
res@lbLabelAutoStride = True ; ensure no label overlap


gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

res@tiMainString="MISR_AM1_TC_ALBEDO_P223_O056884_F05_0011_AlbedoLocal.hdf" ; create title
plot=new(2, "graphic") ; allocate plot
res@gsnLeftString="Field name: AlbedoLocal at SOMBlockDim=50 NBandDim=0"
res@gsnRightString="Units:"
res@gsnLeftStringFontHeightF=9 ; make text smaller
res@gsnRightStringFontHeightF=9

plot(0)=gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first

delete(res@tiMainString) ; delete title for subsequent plots


res@mpLimitMode         = "LatLon"
res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
res@mpMaxLatF	= max(data@lat2d) ; 
res@mpMinLonF	= min(data@lon2d) ;
res@mpMaxLonF	= max(data@lon2d) ;


res@gsnLeftString="Field name: AlbedoLocal at SOMBlockDim=50 NBandDim=0"
res@gsnRightString="Units:"
plot(1)=gsn_csm_contour_map_ce(xwks,data,res) ; 


delete(plot) ; cleaning up resources used
delete(xwks)
delete(data)
delete(res)

end
