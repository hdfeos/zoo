;This example code illustrates how to access and visualize GESDISC_AIRS Swath in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).



load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 2-D grid file data field at subset location.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("AIRS.2005.01.01.L3.CO2Std031.v5.4.12.67.X09261141415.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

data=eos_file->mole_fraction_of_carbon_dioxide_in_free_troposphere_CO2(:,:) ; read data field
; In order to read the mole_fraction_of_carbon_dioxide_in_free_troposphere data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

data@lon2d=eos_file->Longitude_CO2 ; associate longitude and latitude
data@lat2d=eos_file->Latitude_CO2



xwks=gsn_open_wks("pdf","mole_fraction_of_carbon_dioxide_in_free_troposphere_north") ; open workstation



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

res@mpLimitMode="LatLon" ; limit map by latitude/longitude
res@mpMinLatF=0 ; only plot northern hemisphere

gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
res@tiMainString = "AIRS.2005.01.01.L3.CO2Std031.v5.4.12.67.X09261141415.hdf" ; create title
res@gsnCenterString="mole_fraction_of_carbon_dioxide_in_free_troposphere, northern hemisphere only"
plot=gsn_csm_contour_map_ce(xwks,data,res) ; create plot

delete(plot) ; cleaning up used resources
delete(data)
delete(res)
delete(eos_file)
end




