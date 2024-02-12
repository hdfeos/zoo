;This example code illustrates how to access and visualize GESDISC_TRMM file in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo),
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 2-D swath file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.


begin
eos_file=addfile("2A25_CSI.990804.9692.KORA.6.HDF", "r") ; Read file. 
; Since the file is not HDF-EOS, it is not necessary to append .he2 

data=eos_file->nearSurfZ; here, because the file is not HDF-EOS2, it is not necessary to append the group name


data@lon2d=eos_file->geolocation(:,:,1); associate longitude and latitude
data@lat2d=eos_file->geolocation(:,:,0); here, both longitude and latitude are stored in the same data field,
; but with different subsets.

data@_FillValue=0h ; the 'h' after the value is a shortcut for invoking inttoshort() which converts a 32-bit 
; integer to 16-bit in order to avoid type mismatching
data@_FillValue=-9999h ; the reason the FillValue is set twice is to first assign all the 0's in the data field as
; the _FillValue attribute(since the attribute is missing), then set all those 0's to -9999 
; This is an artificial fill value used to allow 0 to be represented as a missing value


xwks=gsn_open_wks("pdf","2A25_CSI.990804.9692.KORA.6_nearSurfZ") ; open workstation

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




gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

res@tiMainString="2A25_CSI.990804.9692.KORA.6.HDF" ; create title
plot=new(2, "graphic") ; allocate plot

res@gsnCenterString="nearSurfZ" ; create center text
plot(0)=gsn_csm_contour_map_ce(xwks,data,res)
delete(res@tiMainString) ; delete title for subsequent plots

res@mpLimitMode         = "LatLon"
res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
res@mpMaxLatF	= max(data@lat2d) ; 
res@mpMinLonF	= min(data@lon2d) ;
res@mpMaxLonF	= max(data@lon2d) ;

res@gsnCenterString="nearSurfZ"
plot(1)=gsn_csm_contour_map_ce(xwks,data,res)


delete(plot) ; cleaning up resources used
delete(data)
delete(xwks)
delete(res)

delete(eos_file)
end





