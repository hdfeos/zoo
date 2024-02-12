;This example code illustrates how to access and visualize LaRC_MISR in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 2-D grid file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("MISR_AM1_CGAS_MAR_01_2006_SITE_INTEXB_F06_0021.hdf.he2", "r") ; Read file. 

data=eos_file->Optical_depth_average_AerosolParameterAverage ;read data field



xwks=gsn_open_wks("pdf","MISR_AM1_CGAS_MAR_01_2006_SITE_INTEXB_F06_0021_Optical_depth_average") ; open workstation

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

res@mpProjection="LambertEqualArea"

gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap


res@tiMainString="MISR_AM1_CGAS_MAR_01_2006_SITE_INTEXB_F06_0021.hdf" ; create title
res@gsnCenterString="Optical_depth_average" ; create center text
plot=gsn_csm_contour_map(xwks,data,res) ; 

delete(plot) ; cleaning up resources used
delete(xwks)
delete(data)
delete(res)

delete(eos_file)
end







