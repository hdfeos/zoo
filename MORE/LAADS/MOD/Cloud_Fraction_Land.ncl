;This example code illustrates how to access and visualize LAADS_MOD Swath in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 2-D swath file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("MOD04_L2.A2010001.0000.005.2010005211741.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

data_unscaled=eos_file->Cloud_Fraction_Land_mod04 ; read data field
; In order to read the Cloud_Fraction_Land data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

; if use the following codes:
; scale = data_unscaled@scale_factor
; offset = data_unscaled@add_offset
; data=data_unscaled * scale + offset 
; will get warning:
; warning:Attempt to reference attribute (scale_factor) which is undefined
; warning:Attempt to reference attribute (add_offset) which is undefined
; warning:Attempt to reference attribute (units) which is undefined
; warning:ContourPlotInitialize: no valid values in scalar field; ContourPlot not possible:[errno=1101]
; warning:Attempt to reference attribute (units) which is undefined
; warning:ContourPlotInitialize: no valid values in scalar field; ContourPlot not possible:[errno=1101]
; the scale_factor etc. attribute values can be obtained by using HDFView to browse the file
; in this example, scale_factor = 0.0010000000474974513, and offset = 0.0
data = ( data_unscaled - 0.0 ) * 0.0010000000474974513
data@_FillValue = eos_file->Cloud_Fraction_Land_mod04@_FillValue

lat=eos_file->Latitude_mod04 ; associate longitude and latitude
lat@_FillValue=-999.0
lon=eos_file->Longitude_mod04 
lon@_FillValue=-999.0

data@lat2d=lat;
data@lon2d=lon; 


xwks=gsn_open_wks("pdf","MOD04_L2.A2010001.0000.005.2010005211741_Cloud_Fraction_Land") ; open workstation

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


res@tiMainString="MOD04_L2.A2010001.0000.005.2010005211741.hdf" ; create title
plot=new(5, "graphic") ; allocate plot
; res@gsnCenterString="Cloud_Fraction_Land" ; create center text
res@gsnLeftString="Field name: Cloud_Fraction_Land"
res@gsnRightString="Units: None" ; have to use hard codes to avoid warning message 

plot(0)=gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first
delete(res@tiMainString) ; delete title for subsequent plots


res@mpLimitMode         = "LatLon"
res@mpMinLatF	= min(lat) ; Set limits of map, based on the min/max of the dataset latitude/longitude
res@mpMaxLatF	= max(lat) ; 
;res@mpMinLonF	= min(lon) ;
;res@mpMaxLonF	= max(lon) ;

res@gsnPolar= "SH" ; plot southern hemisphere

; res@gsnCenterString="Cloud_Fraction_Land" ; create center text

res@gsnLeftString="Field name: Cloud_Fraction_Land"
res@gsnRightString="Units: None" ; have to use hard codes to avoid warning message 

plot(1)=gsn_csm_contour_map_polar(xwks,data,res) ; 




delete(plot) ; cleaning up resources used
delete(xwks)
delete(data)
delete(data_unscaled)
delete(res)
delete(eos_file)
end