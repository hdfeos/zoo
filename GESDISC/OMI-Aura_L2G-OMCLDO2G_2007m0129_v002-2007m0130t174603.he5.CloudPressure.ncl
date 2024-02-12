;  This example code illustrates how to access and visualize HDF_EOS5 file in 
; NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"


begin
file_name = "OMI-Aura_L2G-OMCLDO2G_2007m0129_v002-2007m0130t174603.he5"
field_name = "CloudPressure"

; To read HDF-EOS5 files, the file extension must be ".he5".
eos_file = addfile(file_name, "r") 

; List variables available for plots.
print(eos_file);

data_raw=eos_file->CloudPressure_CloudFractionAndPressure

; Geo-location data contains fill values.
lat_raw=eos_file->Latitude_CloudFractionAndPressure
lon_raw=eos_file->Longitude_CloudFractionAndPressure

; Subset at nCandidate=0.
nCandidate = 0
data=data_raw(nCandidate,:,:)
lat=lat_raw(nCandidate,:,:)
lon=lon_raw(nCandidate,:,:)
data@long_name = data_raw@long_name + " at nCandidate=" + nCandidate

; Although using the lat/lon values stored in the file will generate
; the most accurate plot, NCL cannot handle them properly since they have 
; fill/missing values. Thus, we'll plot using the geo-location infromation 
; that NCL figures out automatically.
;
; Uncomment the following two lines if you want to try lat/lon provided in
; the file.
;
; data@lat2d = lat
; data@lon2d = lon
plot_name = file_name + "." + field_name + ".ncl"
xwks   = gsn_open_wks ("pdf", plot_name)    ; open workstation
gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

res=True
res@gsnMaximize=True   ;make plot large
res@gsnPaperOrientation = "portrait"    ;force portrait orientation
res@gsnSpreadColors=True    ; use the entire color spectrum
res@cnFillOn=True   ;enable contour fill
res@cnLinesOn=False   ;turn off contour line
res@cnLineLabelsOn =  False    ;turn off contour line labels
res@cnFillMode="RasterFill"   ;faster
res@lbLabelAutoStride= True
res@lbOrientation="vertical" ;vertical labels

res@tiMainString = file_name
plot=gsn_csm_contour_map(xwks,data,res)

delete(plot)
delete(data)
delete(res)
delete(eos_file)
end
