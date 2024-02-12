;This example code illustrates how to access and visualize GESDISC_AIRS Swath in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 2-D grid file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("AIRS.2002.08.31.L3.RetStd_H001.v5.0.14.0.G07178195754.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

SurfPres_A=eos_file->SurfPres_A_ascending(:,:) ; read data field
; In order to read the SurfPres_A data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

SurfPres_A@lon2d=eos_file->Longitude_location ; associate longitude and latitude
SurfPres_A@lat2d=eos_file->Latitude_location



xwks=gsn_open_wks("pdf","AIRS.2002.08.31.L3.RetStd_H001.v5.0.14.0.G07178195754_SurfPres_A") ; open workstation



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
res@tiMainString = "AIRS.2002.08.31.L3.RetStd_H001.v5.0.14.0.G07178195754.hdf" ; create title
res@gsnCenterString="SurfPres_A"
plot=gsn_csm_contour_map_ce(xwks,SurfPres_A,res) ; create plot

delete(plot) ; cleaning up used resources
delete(SurfPres_A)
delete(res)
delete(eos_file)
end





