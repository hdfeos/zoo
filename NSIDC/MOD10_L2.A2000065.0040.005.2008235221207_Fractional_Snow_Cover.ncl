;This example code illustrates how to access and visualize NSIDC_MODIS Grid file in NCL. 
;If you have any questions, suggestions, comments on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; This is an example of a 2-D grid file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("MOD10_L2.A2000065.0040.005.2008235221207.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

; print(eos_file)

data=eos_file->Fractional_Snow_Cover_MOD_Swath_Snow 
; read data field, getting the clues about eos_file->Fractional_Snow_Cover_MOD_Swath_Snow
; from print(eos_file)

data@_FillValue = 255b

lat=eos_file->Latitude_MOD_Swath_Snow
lon=eos_file->Longitude_MOD_Swath_Snow
; get the clues from print(eos_file)

lat@units="degrees_north"
lon@units="degrees_east"

data@lat2d=lat
data@lon2d=lon

xwks=gsn_open_wks("pdf","MOD10_L2.A2000065.0040.005.2008235221207_Fractional_Snow_Cover.ncl") ; open workstation

setvalues NhlGetWorkspaceObjectId() ; make maximum filesize larger
"wsMaximumSize" : 200000000
end setvalues

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
res@tiMainString = "MOD10_L2.A2000065.0040.005.2008235221207.hdf" ; create title
res@gsnLeftString="Field name: Fractional_Snow_Cover"
res@gsnRightString="Units: none"

plot=gsn_csm_contour_map_ce(xwks,data,res) ; create plot

delete(plot) ; cleaning up used resources
delete(xwks)
delete(data)
delete(res)
delete(eos_file)

end