
load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 2-D grid file data field with 1 dimensional coordinate variables.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("MOP03-20000303-L3V1.0.1.hdf.he2", "r") ; Read file. 

data=eos_file->Surface_Temperature_Day_MOP03 ; read data field subset
data@lat1d=eos_file->Latitude_MOP03;
data@lon1d=eos_file->Longitude_MOP03;
data@_FillValue=-9999

xwks=gsn_open_wks("pdf","MOP03-20000303-L3V1.0.1_Surface_Temperature_Day") ; open workstation

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



gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap


res@tiMainString="MOP03-20000303-L3V1.0.1.hdf" ; create title
res@gsnCenterString="Surface_Temperature_Day" ; create center text
plot=gsn_csm_contour_map_ce(xwks,data,res) ; 

delete(plot) ; cleaning up resources used
delete(xwks)
delete(data)
delete(res)

delete(eos_file)
end









