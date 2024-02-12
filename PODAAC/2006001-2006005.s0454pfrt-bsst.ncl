;This example code illustrates how to access and visualize PODAAC file in NCL. 
;If you have any questions, suggestions, comments on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

hdf_file = addfile("2006001-2006005.s0454pfrt-bsst.hdf", "r")

bsst = hdf_file->bsst

bsst@_FillValue=0h
bsst@_FillValue=-1h

scale = bsst@scale_factor
offset = bsst@add_off


; The name of offset attribute of bsst is add_off, this names is not included in standard
; offset names: "add_offset", "OFFSET", "Offset", "_offset", "Intercept", "intercept", 
; so we have to manually calculate the value of data, and cannot directly use short2flt()
; use printVarSummary(scale), then you can find scale is type float
; use printVarSummary(offset), then you can find offset is type float

data = scale * int2flt(ushorttoint(bsst)) + offset


data!0="lat" ; This file does not contain geolocation fields. 
data!1="lon" ; To properly display the data, the latitude/longitude must be remapped from its metadata.
; See http://www.ncl.ucar.edu/Applications/Scripts/regrid_10.ncl for more information


lat = hdf_file->lat
lat@units = lat@unit  ; Correct attribute name from "unit" to "units".
lon = hdf_file->lon
lon@units = lon@unit  ; Correct attribute name from "unit" to "units".
   
data&lat = lat
data&lon = lon

xwks = gsn_open_wks("pdf","2006001-2006005.s0454pfrt-bsst")

; Without this, we'll get errors sicne dataset is big.
setvalues NhlGetWorkspaceObjectId()     ; make maximum filesize larger
"wsMaximumSize" : 200000000
end setvalues

; The following resource setup is borrowed from
;
; GESDISC_TRMM/3B43.070901.6A/precipitation.ncl
; 
; by Tong Qi.
res=True                                ; plot mods desired
res@cnFillOn=True                       ; enable contour fill
res@gsnMaximize=True                    ; make plot large
res@gsnPaperOrientation = "portrait"    ; force portrait orientation
res@cnLinesOn=False                     ; turn off contour lines
res@cnLineLabelsOn       =  False       ; turn off contour line labels
res@gsnSpreadColors=True                ; use the entire color spectrum
res@cnFillMode="RasterFill"             ; faster
res@lbOrientation="vertical"            ; vertical labels
res@cnMissingValFillPattern = 0         ; missing value pattern is set to "SolidFill"
res@cnMissingValFillColor=0             ; white color for missing values
res@lbLabelAutoStride = True            ; ensure no label overlap

gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

res@tiMainString="2006001-2006005.s0454pfrt-bsst.hdf" ; title name
res@gsnLeftString = "FIELD NAME: bsst"

; res@gsnRightString = "UNITS: " + bssts@units
; originally units value from the hdf file is Temp, it is some kind of typo
; here I just correct it

res@gsnRightString = "UNITS: degrees-C" 


plot=gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first


delete(plot) ; cleaning up resources used
delete(lat)
delete(lon)
delete(xwks)
delete(data)
delete(res)
delete(hdf_file)
end