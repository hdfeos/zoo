;This example code illustrates how to access and visualize NSIDC_AMSR_E Swath in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; This is an example of a 2-D grid file data field at subset location.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("AMSR_E_L3_WeeklyOcean_V03_20020616.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.


; To restrict the data to only the subset region, the region_ind function is called.
; For more information, visit http://www.ncl.ucar.edu/Document/Functions/Contributed/region_ind.shtml



data=eos_file->High_res_cloud_GlobalGrid(:,0:719) ; read data field subset

; In order to read the High_res_cloud data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

data@units="mm"
data@_FillValue=-9999h ; 'h' is appended to ensure no type mismatching


xwks=gsn_open_wks("pdf","AMSR_E_L3_WeeklyOcean_V03_20020616_High_res_cloud_west") ; open workstation



res=True ; plot mods desired
res@cnFillOn=True ; enable contour fill
res@gsnMaximize=True; make plot large
res@gsnAddCyclic=False ; set to false for data that does not cover whole globe
res@gsnPaperOrientation =	"portrait" ; force portrait orientation
res@cnLinesOn=False ; turn off contour lines
res@cnLineLabelsOn       =  False; turn off contour line labels
res@gsnSpreadColors=True ; use the entire color spectrum
res@cnFillMode="RasterFill" ; faster
res@lbOrientation="vertical" ;vertical labels
res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
res@cnMissingValFillColor=0; white color for missing values

res@mpMaxLonF=0 ; plot only western hemisphere

gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
res@tiMainString = "AMSR_E_L3_WeeklyOcean_V03_20020616.hdf" ; create title
res@gsnCenterString="High_res_cloud"
plot=gsn_csm_contour_map_ce(xwks,data,res) ; create plot

delete(plot) ; cleaning up used resources
;delete(ji)
;delete(glon2d)
;delete(glat2d)
delete(xwks)
delete(data)
delete(res)
delete(eos_file)
end










