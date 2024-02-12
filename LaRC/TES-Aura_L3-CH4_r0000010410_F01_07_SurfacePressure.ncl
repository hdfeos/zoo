;This example code illustrates how to access and visualize HDF_EOS5 TES L3 Grid file in NCL. 
;If you have any questions, suggestions, comments on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; This is an example of a 3-D grid file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("TES-Aura_L3-CH4_r0000010410_F01_07.he5", "r") ; Read file. 
;To read HDF-EOS5 files, .he5 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

data_0=eos_file->SurfacePressure_NadirGrid
data=transpose(data_0)

lat=eos_file->Latitude_NadirGrid
lon=eos_file->Longitude_NadirGrid

data!0="lat" ; This file does not contain coordinate variables. 
data!1="lon" ; To properly display the data, the latitude/longitude must be remapped from its metadata.

lat@units="degree_north"
lon@units="degrees_east"

data&lat=lat
data&lon=lon

xwks   = gsn_open_wks ("pdf","TES-Aura_L3-CH4_r0000010410_F01_07_SurfacePressure.ncl")    ; open workstation
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
res@lbOrientation        = "Vertical"

res@tiMainString = "TES-Aura_L3-CH4_r0000010410_F01_07.he5"
res@gsnLeftString="SurfacePressure" ; create center text
plot=gsn_csm_contour_map(xwks,data,res)


delete(plot)
delete(data_0)
delete(data)
delete(res)
delete(eos_file)
end
