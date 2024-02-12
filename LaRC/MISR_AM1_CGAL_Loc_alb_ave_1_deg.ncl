;This example code illustrates how to access and visualize LaRC_MISR Grid file in NCL. 
;If you have any questions, suggestions, comments on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 3-D grid file data field at various levels.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("MISR_AM1_CGAL_2005_F06_0012.hdf.he2", "r") ; Read file. 

data=eos_file->Local_albedo_average___1_deg_AlbedoAverage_1_degree(:,:,0) ; read specific subset of data field
 

data_1=eos_file->Local_albedo_average___1_deg_AlbedoAverage_1_degree(:,:,1)


data_2=eos_file->Local_albedo_average___1_deg_AlbedoAverage_1_degree(:,:,2)

data_3=eos_file->Local_albedo_average___1_deg_AlbedoAverage_1_degree(:,:,4)



xwks=gsn_open_wks("pdf","MISR_AM1_CGAL_2005_F06_0012_Local_albedo_average__1_deg") ; open workstation

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

res@cnLevelSelectionMode="ManualLevels" ; preset range defined to ensure uniform color legend across all levels
res@cnLevelSpacingF=.05 ; set interval
res@cnMinLevelValF=0 ; set min and max values
res@cnMaxLevelValF=1 ;

gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap


res@tiMainString="MISR_AM1_CGAL_2005_F06_0012.hdf" ; create title
plot=new(4, "graphic") ; allocate plot
res@gsnCenterString="Local_albedo_average__1_deg at Band=0" ; create center text
plot(0)=gsn_csm_contour_map_ce(xwks,data,res) ; 
delete(res@tiMainString) ; delete title for subsequent plots

res@gsnCenterString="Local_albedo_average__1_deg at Band=1" ; create center text
plot(1)=gsn_csm_contour_map_ce(xwks,data_1,res) ; 


res@gsnCenterString="Local_albedo_average__1_deg at Band=2"
plot(2)=gsn_csm_contour_map_ce(xwks,data_2,res)

res@gsnCenterString="Local_albedo_average__1_deg at Band=4"
plot(3)=gsn_csm_contour_map_ce(xwks,data_3,res)






delete(plot) ; cleaning up resources used
delete(xwks)
delete(data)
delete(data_1)
delete(data_2)
delete(data_3)
delete(res)

delete(eos_file)
end





