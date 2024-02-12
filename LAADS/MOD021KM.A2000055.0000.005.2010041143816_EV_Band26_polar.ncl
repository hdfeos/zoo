;This example code illustrates how to access and visualize LAADS_MOD swath file in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; This is an example of a 3-D swath file data field at various levels.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("MOD021KM.A2000055.0000.005.2010041143816.hdf", "r") ; Read file. 

geo_file=addfile("MOD03.A2000055.0000.005.2010029175839.hdf", "r") ; Read geolocation file.
; Because dimension maps are used in the eos_file, we must use geolocation values that are stored in a secondary file.

; print(eos_file)
; print(geo_file)

data_unsigned=eos_file->EV_Band26 ; read data field, the clues about eos_file->EV_Band26 are from print(eos_file)

data_signed=where(data_unsigned.lt.inttoshort(0), abs(data_unsigned)+32767, data_unsigned) ;
; Convert unsigned integer to signed integer for NCL to properly handle

; In order to read the EV_Band26 data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.
data_unscaled   = data_signed

; corrected_counts_scales = 0.12619403, corrected_counts_offsets = 316.9722 from the field attributes.
data = (data_unscaled - 316.9722) * 0.12619403 

data@_FillValue=65535h


data@lat2d=geo_file->Latitude ; associate longitude and latitude, the clues about geo_file->Latitude come from print(geo_file)
data@lon2d=geo_file->Longitude  


xwks=gsn_open_wks("pdf","MOD021KM.A2000055.0000.005.2010041143816_EV_Band26_polar.ncl") ; open workstation

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

res@tiMainString="MOD021KM.A2000055.0000.005.2010041143816.hdf" ; create title
res@gsnLeftString="Field name: EV_Band26"
res@gsnRightString="Units: Watts/m^2/micrometer/steradian"
res@gsnLeftStringFontHeightF=10 ; make text smaller
res@gsnRightStringFontHeightF=10


;res@mpLimitMode = "LatLon"
;res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
;res@mpMaxLatF	= max(data@lat2d) ; 
;res@mpMinLonF	= min(data@lon2d) ;
;res@mpMaxLonF	= max(data@lon2d) ;

res@gsnPolar = "NH" ; specify the hemisphere
plot=gsn_csm_contour_map_polar(xwks,data,res) ; create the plot

; plot=gsn_csm_contour_map_ce(xwks,data,res)


delete(plot) ; cleaning up resources used
delete(xwks)
delete(data_unsigned)
delete(data_signed)
delete(data_unscaled)
delete(data)
delete(res)
delete(geo_file)
delete(eos_file)
end