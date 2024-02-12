;This example code illustrates how to access and visualize LP_DAAC_MOD Grid in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; This is an example of a 2-D grid file data field at subset locataion.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("MOD11C2.A2007073.005.2007098050130.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

data_unsigned=eos_file->LST_Night_CMG_MODIS_8DAY_0_05DEG_CMG_LST(:,:) ; read data field
; In order to read the LST_Night_CMG data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.


data=where(data_unsigned.lt.inttoshort(0), abs(data_unsigned)+32767, data_unsigned)*0.02 ;
data@units="K"
data@_FillValue=0h ; 'h' is appended to ensure no type mismatching
data@_FillValue=-9999h ; The double assignment allows '0' to be represented as a fill value

data!0="lat" ; This file contains coordinate variables that will not properly plot. 
data!1="lon" ; To properly display the data, the latitude/longitude must be remapped.
; See http://www.ncl.ucar.edu/Applications/Scripts/regrid_10.ncl for more information

lat=latGlobeFo(3600, "lat", "latitude", "degrees_north") 
lon=lonGlobeFo(7200, "lon", "longitude", "degrees_east")

lat=lat(::-1) ; use north-to-south latitude ordering
lon=(/ lon - 180. /) ; Span 180W to 180E instead of 0 to 360
lon&lon=lon ; update longitude

data&lat=lat
data&lon=lon






xwks=gsn_open_wks("pdf","MOD11C2.A2007073.005.2007098050130_LST_Night_CMG_west") ; open workstation


setvalues NhlGetWorkspaceObjectId() ; make maximum filesize larger
"wsMaximumSize" : 200000000
end setvalues

res=True ; plot mods desired
res@cnFillOn=True ; enable contour fill
res@gsnMaximize=True; make plot large
res@gsnPaperOrientation =	"portrait" ; force portrait orientation
res@gsnAddCyclic=False ; set to false for data that does not cover whole globe

res@cnLinesOn=False ; turn off contour lines
res@cnLineLabelsOn       =  False; turn off contour line labels
res@gsnSpreadColors=True ; use the entire color spectrum
res@cnFillMode="RasterFill" ; faster
res@lbOrientation="vertical" ;vertical labels
res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
res@cnMissingValFillColor=0; white color for missing values

res@mpMaxLonF=0 ; plot only western hemisphere

gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
res@tiMainString = "MOD11C2.A2007073.005.2007098050130.hdf" ; create title
res@gsnCenterString="LST_Night_CMG"
plot=gsn_csm_contour_map_ce(xwks,data,res) ; create plot




delete(plot) ; cleaning up used resources
delete(data_unsigned)
delete(xwks)
delete(data)
delete(res)
delete(eos_file)
end




















