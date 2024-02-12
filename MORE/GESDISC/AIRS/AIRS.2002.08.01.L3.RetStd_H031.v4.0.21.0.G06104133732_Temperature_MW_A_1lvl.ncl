;This example code illustrates how to access and visualize GESDISC_AIRS Swath in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 3-D grid file data field at one specific level.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("AIRS.2002.08.01.L3.RetStd_H031.v4.0.21.0.G06104133732.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.


data_11=eos_file->Temperature_MW_A_ascending_MW_only(11,:,:) ; read specific subset of data field
; In order to read the Temperature_MW_A data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

data_11@lon2d=eos_file->Longitude_location ; associate longitude and latitude
data_11@lat2d=eos_file->Latitude_location
data_11@_FillValue=-9999

xwks=gsn_open_wks("pdf","AIRS.2002.08.01.L3.RetStd_H031.v4.0.21.0.G06104133732_Temperature_MW_A_1lvl") ; open workstation


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


gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

res@tiMainString="AIRS.2002.08.01.L3.RetStd_H031.v4.0.21.0.G06104133732.pdf" ; create title
res@gsnCenterString="Temperature_MW_A at H20PrsLvls=11" ; create center text
plot=gsn_csm_contour_map_ce(xwks,data_11,res) ; create plot

delete(plot) ; cleaning up resources used
delete(data_11)
delete(res)
delete(eos_file)
end



