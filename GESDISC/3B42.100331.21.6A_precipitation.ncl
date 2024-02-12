;This example code illustrates how to access and visualize GESDISC_TRMM file in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo),
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; This is an example of a 3-D data field at one level.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("3B42.100331.21.6A.hdf", "r") ; Read file. 
; Since the file is not HDF-EOS2, it is not necessary to append .he2

data=eos_file->precipitation(0,:,:) ; read data field
; Here, because the file is not HDF-EOS2, it is not necessary to append the group name

data@_FillValue=0h ; turn 0's to an arbitrary fill value in order to display 0 correctly
data@_FillValue=-9999h

data!0="lon" ; This file does not contain coordinate variables. 
data!1="lat" ; To properly display the data, the latitude/longitude must be remapped from its metadata.
; See http://www.ncl.ucar.edu/Applications/Scripts/regrid_10.ncl for more information


dimsize = dimsizes(data)
numlon = dimsize(0) ; 1440 (from precipitation in hdf file)
numlat = dimsize(1) ; 400 (from precipitation in hdf file)

; http://disc.sci.gsfc.nasa.gov/additional/faq/precipitation_faq.shtml#lat_lon
lat=fspan(-49.875,49.875,numlat)
lon=fspan(-179.875,179.875,numlon)

lat@units="degrees_north"
lon@units="degrees_east"

data&lat=lat
data&lon=lon


xwks=gsn_open_wks("pdf","3B42.100331.21.6A_precipitation") ; open workstation

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


res@tiMainString="3B42.100331.21.6A.HDF" ; create title

res@gsnCenterString="        precipitation at scan=0" ; create center text
res@gsnLeftString="FIELD NAME: precipitation"
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