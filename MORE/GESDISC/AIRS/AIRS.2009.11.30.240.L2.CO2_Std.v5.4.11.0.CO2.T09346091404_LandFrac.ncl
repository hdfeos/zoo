;This example code illustrates how to access and visualize GESDISC_AIRS Swath in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).



load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 2-D swath file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.


begin
eos_file=addfile("AIRS.2009.11.30.240.L2.CO2_Std.v5.4.11.0.CO2.T09346091404.hdf.he2", "r") ; read file
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.


data=eos_file->LandFrac_CO2 ; read data field
; In order to read the LandFrac data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

data@lon2d=eos_file->Longitude_CO2  ; associate longitude and latitude
data@lat2d=eos_file->Latitude_CO2
data@_FillValue= -9999.0 

xwks=gsn_open_wks("pdf","AIRS.2009.11.30.240.L2.CO2_Std.v5.4.11.0.CO2.T09346091404_LandFrac") ; open workstation 

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

res@mpLimitMode         = "LatLon"
res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
res@mpMaxLatF	= max(data@lat2d) ; 
res@mpMinLonF	= min(data@lon2d) ;
res@mpMaxLonF	= max(data@lon2d) ;

;res@gsnPolar   = "NH" ; set polar plot to northern hemisphere

gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

res@tiMainString="AIRS.2009.11.30.240.L2.CO2_Std.v5.4.11.0.CO2.T09346091404.hdf" ; create title
res@gsnCenterString="LandFrac" ; create center text

plot=gsn_csm_contour_map_ce(xwks,data,res) ; create plot

delete(plot) ; cleaning up resources used
delete(data)
delete(res)
delete(eos_file)
end


