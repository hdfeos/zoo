;This example code illustrates how to access and visualize GESDISC_TRMM file in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo),
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; This is an example of a 4-D data field at one level.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("3A46.080101.2.HDF", "r") ; Read file. 
; Since the file is not HDF-EOS2, it is not necessary to append .he2

data=eos_file->ssmiData(0,0,:,:) ; read data field
; Here, because the file is not HDF-EOS2, it is not necessary to append the group name



;data=transpose(data_old)
data@_FillValue=-9999.9 ; turn -9999.9's to an arbitrary fill value in order to display 0 correctly


;latitude/longitude must be remapped from its metadata.
;http://disc.sci.gsfc.nasa.gov/precipitation/documentation/TRMM_README/TRMM_3A46_readme.shtml


dimsize = dimsizes(data)
numlon = dimsize(1) ; 360 
numlat = dimsize(0) ; 180 

;http://disc.sci.gsfc.nasa.gov/additional/faq/precipitation_faq.shtml#lat_lon
lat=fspan(89.5,-89.5,numlat)
lon=fspan(-359.5,0.5,numlon)
lon(0:179)=lon(0:179)+360

lat@units="degrees_north"
lon@units="degrees_east"

data!1="lon" ; This file does not contain coordinate variables. 
data!0="lat" ; To properly display the data, the 

data&lat = lat    ; assign values to named dimension
data&lon = lon

xwks=gsn_open_wks("pdf","3A46.080101.2_ssmiData_test") ; open workstation

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
res@cnMissingValFillColor=0 ; white color for missing values
res@lbLabelAutoStride = True ; ensure no label overlap


gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap


res@tiMainString="3A46.080101.2.HDF" ; create title

res@gsnLeftString="FIELD NAME: ssmiData"
res@gsnCenterString="Precipitation Rate"
res@gsnRightString="UNITS: mm/hr"

;To reorder dimensions in NCL
; you need to specify the coordinate variable name followed by a |   
; so, in the current case:

plot=gsn_csm_contour_map_ce(xwks,data(lat|:,lon|:),res)


; cleaning up resources used
delete(plot)
delete(xwks)
delete(data)
delete(res)
delete(eos_file)
end
