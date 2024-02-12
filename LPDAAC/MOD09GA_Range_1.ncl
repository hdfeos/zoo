;This example code illustrates how to access and visualize LP_DAAC_MOD Grid file in NCL. 
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
eos_file=addfile("MOD09GA.A2007268.h10v08.005.2007272184810.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

data_unsigned=eos_file->Range_1_MODIS_Grid_1km_2D(:,:) ; read data field
; In order to read the Range_1 data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.


data_unscaled = where(data_unsigned.lt.inttoshort(0),abs(data_unsigned)+32767,data_unsigned) 
; Convert unsigned int to signed int

data = data_unscaled * 25.0 ; scale_factor=25.0 from the Range_1's attributes

data@lat2d=eos_file->GridLat_MODIS_Grid_1km_2D
data@lon2d=eos_file->GridLon_MODIS_Grid_1km_2D
data@units="meters"

;data@_FillValue=-9999h ; 'h' is appended to ensure no type mismatching. An artificial value is used in order
; to properly display 0 as a Fill Value



xwks=gsn_open_wks("pdf","MODIS_Grid_1km_2D_Range_1_new") ; open workstation
; printMinMax(data, True)
; print(data(0,0))

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
res@tiMainString = "MOD09GA.A2007268.h10v08.005.2007272184810.hdf" ; create title
; res@gsnCenterString="Range_1"
res@gsnLeftString="Field name: Range_1"
res@gsnRightString="Units: " + data@units

plot=gsn_csm_contour_map_ce(xwks,data,res) ; create plot

delete(plot) ; cleaning up used resources
delete(xwks)
delete(data_unsigned)
delete(data)
delete(data_unscaled )
delete(res)
delete(eos_file)
end

