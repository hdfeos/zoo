
load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 2-D swath file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("MOD07_L2.A2010001.0000.005.2010004001518.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.


data_unscaled=eos_file->Total_Ozone_mod07 ; read data field
; In order to read the Total_Ozone data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

data=data_unscaled*0.10000000149011612; scale factor given from the file
data@lat2d=eos_file->Latitude_mod07 ; associate longitude and latitude
data@lon2d=eos_file->Longitude_mod07 ; 
data@units="Dobson"




xwks=gsn_open_wks("pdf","MOD07_L2.A2010001.0000.005.2010004001518_Total_Ozone") ; open workstation

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






gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap


res@tiMainString="MOD07_L2.A2010001.0000.005.2010004001518.hdf" ; create title
plot=new(5, "graphic") ; allocate plot
res@gsnCenterString="Total_Ozone" ; create center text
plot(0)=gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first
delete(res@tiMainString) ; delete title for subsequent plots


res@mpLimitMode         = "LatLon"
res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
res@mpMaxLatF	= max(data@lat2d) ; 
;res@mpMinLonF	= min(data@lon2d) ;
;res@mpMaxLonF	= max(data@lon2d) ;

res@gsnPolar= "SH" ; plot southern hemisphere

res@gsnCenterString="Total_Ozone" ; create center text
plot(1)=gsn_csm_contour_map_polar(xwks,data,res) ; 




delete(plot) ; cleaning up resources used
delete(xwks)
delete(data)
delete(data_unscaled)
delete(res)
delete(eos_file)
end





