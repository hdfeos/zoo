;This example code illustrates how to access and visualize GESDISC_TOMS in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 4-D grid file data field at various levels.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.


begin
eos_file=addfile("MOD08_D3.A2002001.004.2003182161017.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

data=eos_file->Cloud_Top_Pressure_Night_Joint_Histogram_vs_Emissivity_mod08(0,0,:,:) ; read specific subset of data field
; In order to read the radiances data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

data@lon1d=eos_file->XDim_mod08 ; associate longitude and latitude
data@lat1d=eos_file->YDim_mod08
data@_FillValue=inttoshort(-9999) ; inttoshort() converts a 32-bit integer to a 16-bit integer
; this is to avoid a type mismatch, since the data is 16 bits

data_1=eos_file->Cloud_Top_Pressure_Night_Joint_Histogram_vs_Emissivity_mod08(1,1,:,:) 
data_1@lon1d=eos_file->XDim_mod08 
data_1@lat1d=eos_file->YDim_mod08
data_1@_FillValue=inttoshort(-9999) 

data_2=eos_file->Cloud_Top_Pressure_Night_Joint_Histogram_vs_Emissivity_mod08(2,2,:,:) 
data_2@lon1d=eos_file->XDim_mod08 
data_2@lat1d=eos_file->YDim_mod08
data_2@_FillValue=inttoshort(-9999) 



xwks=gsn_open_wks("pdf","MOD08_D3.A2002001.004.2003182161017_Cloud_Top_Pressure_Night_Joint_Histogram_vs_Emissivity") ; open workstation

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

res@gsnCenterStringFontHeightF=10 ; make font smaller

res@cnLevelSelectionMode="ManualLevels" ; preset range defined to ensure uniform color legend across all levels
res@cnLevelSpacingF=25 ; set interval
res@cnMinLevelValF=25 ; set min and max values
res@cnMaxLevelValF=600 ;

gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

res@tiMainString="MOD08_D3.A2002001.004.2003182161017.hdf" ; create title
plot=new(3, "graphic") ; allocate plot


;res@mpLimitMode         = "LatLon"
;res@mpMinLatF	= min(data@lat1d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
;res@mpMaxLatF	= max(data@lat1d) ; 
;res@mpMinLonF	= min(data@lon1d) ;
;res@mpMaxLonF	= max(data@lon1d) ;

res@gsnCenterString="Cloud_Top_Pressure_Night_Joint_Histogram_vs_Emissivity at Cloud_Effective_Emissivity_Joint_Histo_Intervals=0, Cloud_Top_Pressure_Joint_Histo_Intervals=0" 
plot(0)=gsn_csm_contour_map_ce(xwks,data,res)

delete(res@tiMainString) ; delete title for subsequent plots

res@gsnCenterString="Cloud_Top_Pressure_Night_Joint_Histogram_vs_Emissivity at Cloud_Effective_Emissivity_Joint_Histo_Intervals=1, Cloud_Top_Pressure_Joint_Histo_Intervals=1"
plot(1)=gsn_csm_contour_map_ce(xwks,data_1,res)

res@gsnCenterString="Cloud_Top_Pressure_Night_Joint_Histogram_vs_Emissivity at Cloud_Effective_Emissivity_Joint_Histo_Intervals=2, Cloud_Top_Pressure_Joint_Histo_Intervals=2"
plot(2)=gsn_csm_contour_map_ce(xwks,data_2,res)


delete(plot) ; cleaning up resources used
delete(xwks)
delete(data)
delete(data_1)
delete(data_2)

delete(res)

delete(eos_file)
end



