;This example code illustrates how to access and visualize GESDISC_AIRS Swath in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).



load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 3-D swath file data field at one specific level.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.


begin
eos_file=addfile("AIRS.2002.12.31.001.L2.CC_H.v4.0.21.0.G06100185050.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

data=eos_file->radiances_L2_Standard_cloud_cleared_radiance_product(:,:,0) ; read data field
; In order to read the CldClearParam data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

data@lon2d=eos_file->Longitude_L2_Standard_cloud_cleared_radiance_product ; associate longitude and latitude
data@lat2d=eos_file->Latitude_L2_Standard_cloud_cleared_radiance_product
data@_FillValue=-9999

xwks=gsn_open_wks("pdf","AIRS.2002.12.31.001.L2.CC_H.v4.0.21.0.G06100185050_radiances_1lvl") ; open workstation

res=True ; plot mods desired
res@cnFillOn=True ; enable contour fill
res@cnLinesOn=False ; turn off contour lines
res@gsnSpreadColors=True ; use the entire color spectrum
res@gsnMaximize=True; make plot large
res@gsnPaperOrientation="portrait" ; force portrait orientation
res@cnFillMode="RasterFill" ; faster
res@lbLabelAutoStride=True ; ensure labels do not overlap
res@lbOrientation = "vertical" ; vertical labels
res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
res@cnMissingValFillColor=0; white color for missing values

res@mpLimitMode         = "LatLon"
res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
res@mpMaxLatF	= max(data@lat2d) ; Since this is a polar projection, only latitude need be set
;res@mpMinLonF	= min(data@lon2d) ;
;res@mpMaxLonF	= max(data@lon2d) ;

res@gsnPolar   = "SH" ; set polar plot to southern hemisphere

gsn_define_colormap(xwks,"amwg") ; define colormap

res@tiMainString="AIRS.2002.12.31.001.L2.CC_H.v4.0.21.0.G06100185050.hdf" ; create title
res@gsnCenterString="radiances at Channel=0" ; create center text
plot=gsn_csm_contour_map_polar(xwks,data,res) ; plot

delete(plot) ; cleaning up used resources
delete(data)
delete(res)
delete(eos_file)
end


