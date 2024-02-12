;This example code illustrates how to access and visualize LP_DAAC_MYD Grid file in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; This is an example of a 2-D grid file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("MYD13A1.A2006321.h10v05.004.2006341182856.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

data_unscaled = eos_file->500m_16_days_NDVI_MODIS_Grid_16DAY_500m_VI(:,:) ; read data field
; In order to read the 500m_16_days_NDVI data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

data_unscaled@units="NDVI"
data_unscaled@_FillValue=-3000h ; 'h' is appended to ensure no type mismatching.

data = (data_unscaled - 0.0) * 10000.0 ; scale_factor = 10000.0, add_offset = 0.0 from the field attributes

data@lat2d=eos_file->GridLat_MODIS_Grid_16DAY_500m_VI
data@lon2d=eos_file->GridLon_MODIS_Grid_16DAY_500m_VI
;data@units="NDVI"
;data@_FillValue=-3000h ; 'h' is appended to ensure no type mismatching.


xwks=gsn_open_wks("pdf","MYD13A1.A2006321.h10v05.004.2006341182856_500m_16_days_NDVI_new") ; open workstation


res=True ; plot mods desired
res@cnFillOn=True ; enable contour fill
res@gsnMaximize=True; make plot large
res@gsnPaperOrientation =	"portrait" ; force portrait orientation
res@cnLinesOn=False ; turn off contour lines
res@cnLineLabelsOn       =  False; turn off contour line labels
res@gsnSpreadColors=True ; use the entire color spectrum
res@cnFillMode="RasterFill" ; faster
res@lbOrientation="vertical" ;vertical labels
res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
res@cnMissingValFillColor=0; white color for missing values

res@mpLimitMode         = "LatLon"
res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
res@mpMaxLatF	= max(data@lat2d) ; 
res@mpMinLonF	= min(data@lon2d) ;
res@mpMaxLonF	= max(data@lon2d) ;

gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
res@tiMainString = "MYD13A1.A2006321.h10v05.004.2006341182856.hdf" ; create title

res@gsnLeftString="Field name: 500m_16_days_NDVI"
res@gsnRightString="Units: " + data_unscaled@units

plot=gsn_csm_contour_map_ce(xwks,data,res) ; create plot

delete(plot) ; cleaning up used resources
delete(xwks)
delete(data_unscaled)
delete(data)
delete(res)
delete(eos_file)
end













