;This example code illustrates how to access and visualize LaRC_CERES HDF4 file in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 2-D data field using 1-D geolocation.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("CER-NEWS_CCCM_Aqua-FM3-MODIS-CAL-CS_RelA2_903903.20070430.hdf", "r") ; Read file. 
; Since the file is not HDF-EOS2, it is not necessary to append .he2

data=eos_file->CERES_LW_TOA_flux_upwards; read data field
; Here, because the file is not HDF-EOS2, it is not necessary to append the group name

colatitude=eos_file->Colatitude_of_CERES_FOV_at_surface; 

lat=(/ 90. - colatitude /); convert colatitude to latitude
lon=eos_file->Longitude_of_CERES_FOV_at_surface ;


xwks=gsn_open_wks("pdf","CERES_LW_TOA_flux_upwards") ; open workstation

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
res@gsnLeftStringFontHeightF=10 ; make text smaller
res@gsnCenterStringFontHeightF=10
res@gsnRightStringFontHeightF=10

res@sfXArray = lon; associate 1d longitude and latitude
res@sfYArray = lat ; 



gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap


res@tiMainString="CER-NEWS_CCCM_Aqua-FM3-MODIS-CAL-CS_RelA2_903903.20070430.hdf" ; create title
res@gsnCenterString="CERES LW TOA flux - upwards" ; create center text
plot=gsn_csm_contour_map_ce(xwks,data,res) ; 








delete(plot) ; cleaning up resources used
delete(xwks)
delete(data)
delete(lat)
delete(lon)
delete(colatitude)
delete(res)

delete(eos_file)
end




