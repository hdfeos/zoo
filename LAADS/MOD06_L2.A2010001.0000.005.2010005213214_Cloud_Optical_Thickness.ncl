;This example code illustrates how to access and visualize LAADS_MOD swath file in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 2-D swath file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("MOD06_L2.A2010001.0000.005.2010005213214.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

geo_file=addfile("../MOD03.A2010001.0000.005.2010003235220.hdf.he2", "r") ; Read geolocation file.
; Because dimension maps are used in the eos_file, we must use geolocation values that are stored in a 
; secondary file.

data_unscaled=eos_file->Cloud_Optical_Thickness_mod06 ; read data field
; In order to read the Cloud_Optical_Thickness data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

data=data_unscaled*0.009999999776482582; scale factor given from the file
data@lat2d=geo_file->Latitude_MODIS_Swath_Type_GEO(:,:) ; associate longitude and latitude
data@lon2d=geo_file->Longitude_MODIS_Swath_Type_GEO(:,:) ; 

xwks=gsn_open_wks("pdf","MOD06_L2.A2010001.0000.005.2010005213214_Cloud_Optical_Thickness") ; open workstation

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

res@tiMainString="MOD06_L2.A2010001.0000.005.2010005213214.hdf" ; create title
plot=new(5, "graphic") ; allocate plot
res@gsnCenterString="Cloud_Optical_Thickness" ; create center text
plot(0)=gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first
delete(res@tiMainString) ; delete title for subsequent plots

res@mpLimitMode         = "LatLon"
res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
res@mpMaxLatF	= max(data@lat2d) ; 

res@gsnPolar= "SH" ; plot southern hemisphere
res@gsnCenterString="Cloud_Optical_Thickness" ; create center text

plot(1)=gsn_csm_contour_map_polar(xwks,data,res) ; 

delete(plot) ; cleaning up resources used
delete(xwks)
delete(data)
delete(data_unscaled)
delete(res)
delete(eos_file)
end