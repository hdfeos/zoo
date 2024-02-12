;This example code illustrates how to access and visualize NSIDC_MODIS Swath in NCL. 
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
eos_file=addfile("MOD10C1.A2005018.005.2007349093349.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.


; To restrict the data to only the subset region, the region_ind function is called.
; For more information, visit http://www.ncl.ucar.edu/Document/Functions/Contributed/region_ind.shtml



data=eos_file->Day_CMG_Snow_Cover_MOD_CMG_Snow_5km(:,0:3599) ; read data field subset

; In order to read the Day_CMG_Snow_Cover data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.



xwks=gsn_open_wks("pdf","MOD10C1.A2005018.005.2007349093349_Day_CMG_Snow_Cover_west") ; open workstation

setvalues NhlGetWorkspaceObjectId() ; make maximum filesize larger
"wsMaximumSize" : 200000000
end setvalues

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
res@tiMainString = "MOD10C1.A2005018.005.2007349093349.hdf" ; create title
res@gsnCenterString="Day_CMG_Snow_Cover"
plot=gsn_csm_contour_map_ce(xwks,data,res) ; create plot

delete(plot) ; cleaning up used resources
delete(xwks)
delete(data)
delete(res)
delete(eos_file)
end











