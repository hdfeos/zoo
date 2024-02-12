;This example code illustrates how to access and visualize HDF_EOS5 MEaSUREs Grid file in NCL. 
;If you have any questions, suggestions, comments on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("GSSTFYC.2b.Year.1988_2008.he5", "r") ; Read file. 
;To read HDF-EOS5 files, .he5 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

data1=eos_file->H_SET1
data2=eos_file->H_SET2

data1!0="lat" ; This file does not contain coordinate variables. 
data1!1="lon" ; To properly display the data, the latitude/longitude must be remapped from its metadata.

data2!0="lat" ; This file does not contain coordinate variables. 
data2!1="lon" ; To properly display the data, the latitude/longitude must be remapped from its metadata.

dimsize1 = dimsizes(data1)
numlat1 = dimsize1(0) ; 360 (from precipitation in hdf file)
numlon1 = dimsize1(1) ; 180 (from precipitation in hdf file)

dimsize2 = dimsizes(data2)
numlat2 = dimsize2(0) ; 360 (from precipitation in hdf file)
numlon2 = dimsize2(1) ; 180 (from precipitation in hdf file)

lat1=fspan(-90,90,numlat1)
lon1=fspan(-179.875,179.875,numlon1)

lat2=fspan(-90,90,numlat2)
lon2=fspan(-179.875,179.875,numlon2)

lat1@units="degrees_north"
lon1@units="degrees_east"

lat2@units="degrees_north"
lon2@units="degrees_east"

data1&lat=lat1
data1&lon=lon1

data2&lat=lat2
data2&lon=lon2

data1@long_name=data1@LongName
data2@long_name=data2@LongName


xwks   = gsn_open_wks ("pdf","GSSTFYC.2b.Year.1988_2008_Yearly_sensible_heat_flux.ncl")    ; open workstation
gsn_define_colormap(xwks,"amwg")

res=True
res@gsnMaximize=True   ;make plot large
res@gsnPaperOrientation = "portrait"    ;force portrait orientation
res@gsnSpreadColors=True    ; use the entire color spectrum
res@tiMainString = "GSSTFYC.2b.Year.1988_2008 Yearly " + data1@long_name
res@cnFillOn=True   ;enable contour fill
res@cnLinesOn=False   ;turn off contour line
res@cnLineLabelsOn =  False    ;turn off contour line labels
res@lbOrientation="vertical" ; vertical labels
res@cnFillMode="RasterFill"   ;faster
res@lbLabelAutoStride= True

res@gsnLeftString="SET1 " + data1@long_name  ; create left text
plot=gsn_csm_contour_map(xwks,data1,res)
delete(res@tiMainString)

res@gsnLeftString="SET2 " + data2@long_name  ; create left text
plot=gsn_csm_contour_map(xwks,data2,res)

delete(plot)
delete(data1)
delete(data2)
delete(res)
delete(eos_file)
end
