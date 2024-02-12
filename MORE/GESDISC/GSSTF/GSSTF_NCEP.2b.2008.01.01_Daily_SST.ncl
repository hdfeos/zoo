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
eos_file=addfile("GSSTF_NCEP.2b.2008.01.01.he5", "r") ; Read file. 
;To read HDF-EOS5 files, .he5 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

data=eos_file->SST_NCEP

data!0="lat" ; This file does not contain coordinate variables. 
data!1="lon" ; To properly display the data, the latitude/longitude must be remapped from its metadata.

dimsize = dimsizes(data)
numlat = dimsize(0) ; 360 (from precipitation in hdf file)
numlon = dimsize(1) ; 180 (from precipitation in hdf file)

lat=fspan(-90,90,numlat)
lon=fspan(-179.875,179.875,numlon)

lat@units="degrees_north"
lon@units="degrees_east"

data&lat=lat
data&lon=lon

data@long_name=data@LongName

xwks   = gsn_open_wks ("pdf","GSSTF_NCEP.2b.2008.01.01_Daily_SST.ncl")    ; open workstation
gsn_define_colormap(xwks,"amwg")

res=True
res@gsnMaximize=True   ;make plot large
res@gsnPaperOrientation = "portrait"    ;force portrait orientation
res@gsnSpreadColors=True    ; use the entire color spectrum
res@tiMainString = "GSSTF_NCEP.2b.2008.01.01 Daily sea surface skin temperature"
res@cnFillOn=True   ;enable contour fill
res@cnLinesOn=False   ;turn off contour line
res@cnLineLabelsOn =  False    ;turn off contour line labels
res@lbOrientation="vertical" ; vertical labels
res@cnFillMode="RasterFill"   ;faster
res@lbLabelAutoStride= True

tres=True
tres@txFontHeightF = 0.01
gsn_text_ndc(xwks,"NCEP/DOE Reanalysis II in HDF-EOS5",0.25,0.2,tres)

plot=gsn_csm_contour_map(xwks,data,res)

frame(xwks)

delete(plot)
delete(data)
delete(res)
delete(eos_file)
end
