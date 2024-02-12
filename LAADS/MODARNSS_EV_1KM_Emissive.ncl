;This example code illustrates how to access and visualize LAADS_MOD file in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 3-D data field at various levels.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("MODARNSS.Abracos_Hill.A2000080.1515.005.2007164153544.hdf", "r") ; Read file. 
; Since the file is not HDF-EOS2, it is not necessary to append .he2


; Here, because the file is not HDF-EOS2, it is not necessary to append the group name
data_unscaled=eos_file->EV_1KM_Emissive(0,:,:) ; read specific subset of data field
data_unscaled_1=eos_file->EV_1KM_Emissive(5,:,:)
data_unscaled_2=eos_file->EV_1KM_Emissive(10,:,:)
data_unscaled_3=eos_file->EV_1KM_Emissive(15,:,:)


data_unscaled@_FillValue=65535h
data_unscaled_1@_FillValue=65535h
data_unscaled_2@_FillValue=65535h
data_unscaled_3@_FillValue=65535h


; There are 16 scale and offset pairs 
; from EV_1KM_Emissive's attributes: radiance_scales and radiance_offsets,
; so have to hard codes to specify the exactly scale and offset, respectively
data = ( data_unscaled - 2730.5833 ) * 6.2623985E-5
data_1 = ( data_unscaled_1 - 1560.3334 ) * 5.6398207E-5
data_2 = ( data_unscaled_2 - 1577.3397 ) * 8.40022E-4
data_3 = ( data_unscaled_3 - 2501.29790 ) * 1.1833857E-4


data@lat2d=eos_file->Latitude; associate longitude and latitude
data@lon2d=eos_file->Longitude; 


data_1@lat2d=eos_file->Latitude;
data_1@lon2d=eos_file->Longitude; 


data_2@lat2d=eos_file->Latitude; 
data_2@lon2d=eos_file->Longitude; 


data_3@lat2d=eos_file->Latitude; 
data_3@lon2d=eos_file->Longitude; 


xwks=gsn_open_wks("pdf","MODARNSS.Abracos_Hill.A2000080.1515.005.2007164153544_EV_1KM_Emissive") ; open workstation

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


res@mpLimitMode="LatLon"
res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
res@mpMaxLatF	= max(data@lat2d) ; 
res@mpMinLonF	= min(data@lon2d) ; 
res@mpMaxLonF	= max(data@lon2d) ;


gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap


res@tiMainString="MODARNSS.Abracos_Hill.A2000080.1515.005.2007164153544.hdf" ; create title
plot=new(4, "graphic") ; allocate plot
res@gsnCenterString="Band_1KM_Emissive=0" ; create center text
res@gsnLeftString="Field name: EV_1KM_Emissive"
res@gsnRightString="Units: Watts/m^2/micrometer/steradian"
res@gsnLeftStringFontHeightF=9 ; make text smaller
res@gsnCenterStringFontHeightF=9
res@gsnRightStringFontHeightF=9
; res@gsnCenterStringParallelPosF=.7 ; move center string to the right
plot(0)=gsn_csm_contour_map_ce(xwks,data,res) ; 

delete(res@tiMainString) ; delete title for subsequent plots

res@gsnCenterString="Band_1KM_Emissive=5" ; create center text
res@gsnLeftString="Field name: EV_1KM_Emissive"
res@gsnRightString="Units: Watts/m^2/micrometer/steradian"
plot(1)=gsn_csm_contour_map_ce(xwks,data_1,res) ; 

res@gsnCenterString="Band_1KM_Emissive=10"
res@gsnLeftString="Field name: EV_1KM_Emissive"
res@gsnRightString="Units: Watts/m^2/micrometer/steradian"
plot(2)=gsn_csm_contour_map_ce(xwks,data_2,res)

res@gsnCenterString="Band_1KM_Emissive=15"
res@gsnLeftString="Field name: EV_1KM_Emissive"
res@gsnRightString="Units: Watts/m^2/micrometer/steradian"
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





