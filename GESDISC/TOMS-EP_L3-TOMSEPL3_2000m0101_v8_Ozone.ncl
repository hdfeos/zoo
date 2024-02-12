;This example code illustrates how to access and visualize GESDISC_MODIS_TOMS Grid in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 2-D grid file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("TOMS-EP_L3-TOMSEPL3_2000m0101_v8.HDF.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

data=eos_file->Ozone_TOMS_Level_3(:,:) ; read data field
; In order to read the Ozone data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

data@lon1d=eos_file->XDim_TOMS_Level_3 ; associate longitude and latitude
data@lat1d=eos_file->YDim_TOMS_Level_3
data@_FillValue=-9999
data@long_name="Column Amount Ozone"
data@units="DU"

xwks=gsn_open_wks("pdf","TOMS-EP_L3-TOMSEPL3_2000m0101_v8_Ozone") ; open workstation



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


gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
res@tiMainString = "TOMS-EP_L3-TOMSEPL3_2000m0101_v8.hdf" ; create title
res@gsnCenterString="Ozone"
plot=gsn_csm_contour_map_ce(xwks,data,res) ; create plot

delete(plot) ; cleaning up used resources
delete(xwks)
delete(data)
delete(res)
delete(eos_file)
end







