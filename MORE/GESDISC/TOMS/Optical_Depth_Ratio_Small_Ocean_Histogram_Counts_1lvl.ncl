;This example code illustrates how to access and visualize GESDISC_TOMS in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 3-D grid file data field at one specific level.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("MOD08_D3.A2005001.005.2006203153909.ss000500113842.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.


data_11=eos_file->Optical_Depth_Ratio_Small_Ocean_Histogram_Counts_mod08(4,:,:) ; read specific subset of data field
; In order to read the Optical_Depth_Ratio_Small_Ocean_Histogram_Counts data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

data_11@lon1d=eos_file->XDim_mod08 ; associate longitude and latitude
data_11@lat1d=eos_file->YDim_mod08
data_11@_FillValue=inttoshort(-9999); inttoshort() converts a 32-bit integer to a 16-bit integer
; this is to avoid a type mismatch, since the data is 16 bits

xwks=gsn_open_wks("pdf","Optical_Depth_Ratio_Small_Ocean_Histogram_Counts_1lvl") ; open workstation


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

res@gsnCenterStringFontHeightF=10 ; make font smaller

gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

res@tiMainString="MOD08_D3.A2005001.005.2006203153909.ss000500113842.pdf" ; create title
res@gsnCenterString="Optical_Depth_Ratio_Small_Ocean_Histogram_Counts at Optical_Depth_Ratio_Small_Ocean_Histo_Intervals=4" ; create center text
plot=gsn_csm_contour_map_ce(xwks,data_11,res) ; create plot

delete(plot) ; cleaning up resources used
delete(xwks)
delete(data_11)
delete(res)
delete(eos_file)
end




