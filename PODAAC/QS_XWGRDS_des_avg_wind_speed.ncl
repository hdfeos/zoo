;This example code illustrates how to access and visualize PODAAC file in NCL. 
;If you have any questions, suggestions, comments on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"


begin
hdf_file = addfile("QS_XWGRD3_2008001.20080021608.hdf", "r")

wss = hdf_file->des_avg_wind_speed

wss@_FillValue=0h
wss@_FillValue=-1h


; The wss is 16-bit unsigned integer, however, use printVarSummary(wss), then you will find wss is type short
; short2flt() will converts values of type short to values of type float 
; using the "scale" and "offset" attributes (if present). 
; see http://www.ncl.ucar.edu/Document/Functions/Contributed/short2flt.shtml
; short2flt() can handle the following scale and offset:
; scale: "SCALE", "Scale", "_scale", "scale_factor", "Scale_factor", "Slope" , "slope"
; offset: "add_offset", "OFFSET", "Offset", "_offset", "Intercept", "intercept" 
; wss, i.e. des_avg_wind_speed has attributes: scale_factor and add_offset, those attributes can be handled by short2flt()

data = short2flt(wss) 

data!0="lat" ; This file does not contain coordinate variables. 
data!1="lon" ; To properly display the data, the latitude/longitude must be remapped from its metadata.
; See http://www.ncl.ucar.edu/Applications/Scripts/regrid_10.ncl for more information

dimsize = dimsizes(data)

numlat = dimsize(0) ; 720 (from precipitation in hdf file)
numlon = dimsize(1) ; 1440

; define new latitude
lat=new( (/numlat/), float)
lon=new( (/numlon/), float)


; About the calculation of lat and lon,
; see ftp://podaac.jpl.nasa.gov/ocean_wind/quikscat/L3/doc/qscat_L3.pdf

do i = 0, numlon-1
lon(i) = (360. / numlon) * (i + 0.5)
end do

do j = 0, numlat-1
lat(j) = (180. / numlat) * (j + 0.5) - 90.
end do


lat@units="degrees_north"
lon@units="degrees_east"

data&lat=lat
data&lon=lon


xwks = gsn_open_wks("pdf","QS_XWGRD3_2008001.20080021608_des_avg_wind_speed")


res=True                                ; plot mods desired
res@cnFillOn=True                       ; enable contour fill
res@cnLinesOn=False                     ; turn off contour lines
res@gsnSpreadColors=True                ; use the entire color spectrum
res@cnFillMode="RasterFill"             ; faster
res@lbLabelAutoStride=True              ; ensure labels do not overlap
res@lbOrientation = "vertical"          ; vertical labels
res@cnMissingValFillPattern = 0         ; missing value pattern is set to "SolidFill"
res@cnMissingValFillColor=0             ; white color for missing values


; gsn_add_cyclic: Warning: The range of your longitude coordinate array is at least 360.
; You may want to set gsnAddCyclic to False to avoid a warning message from the spline function.
res@gsnAddCyclic = False                 
                                       

gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

res@tiMainString="QS_XWGRD3_2008001.20080021608.hdf" ; create title from file attribute
res@gsnLeftString = "FIELD NAME: " + data@long_name
res@gsnRightString = "UNITS: " + data@units


plot=gsn_csm_contour_map_ce(xwks,data,res)


delete(plot) ; cleaning up resources used
delete(xwks)
delete(data)
delete(res)
delete(hdf_file)
end