;This example code illustrates how to access and visualize NSIDC_MODIS Grid file in NCL. 
;If you have any questions, suggestions, comments on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; This is an example of a 2-D grid file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("MOD10_L2.A2000065.0040.005.2008235221207.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

data_byte=eos_file->Snow_Cover_MOD_Swath_Snow 
; read data field, getting the clues about eos_file->Snow_Cover_MOD_Swath_Snow
; from print(eos_file)

data=byte2flt(data_byte)   ;Convert data type from byte to float
data@_FillValue = 255b

dimsize=dimsizes(data)
nlon=dimsize(0)  ;4060 (from datafield in hdf file)
nlat=dimsize(1)  ;2708 (from datafield in hdf file)

; We need to use eosdump to generate lat and lon
; For information on how to obtain the lat/lon data, check this URL http://hdfeos.org/zoo/note_non_geographic.php

; To properly display the data, the latitude/longitude must be remapped.
lat=asciiread("lat_MOD10_L2.A2000065.0040.005.2008235221207.output",(/nlon,nlat/),"float")
lon=asciiread("lon_MOD10_L2.A2000065.0040.005.2008235221207.output",(/nlon,nlat/),"float")

data@lat2d=lat
data@lon2d=lon

xwks=gsn_open_wks("pdf","MOD10_L2.A2000065.0040.005.2008235221207_Snow_Cover_Polar.ncl")    ; open workstation
gsn_define_colormap(xwks,"amwg")

setvalues NhlGetWorkspaceObjectId() ; make maximum filesize larger
"wsMaximumSize" : 200000000
end setvalues

res=True ;plot mods desired
res@cnFillOn=True   ;enable contour fill
res@gsnMaximize=True   ;make plot large
res@gsnPaperOrientation = "portrait"    ;force prtrait orientation
res@cnLinesOn=False   ;turn off contour line
res@cnLineLabelsOn =  False    ;turn off contour line labels
res@gsnSpreadColors=True    ; use the entire color spectrum
res@cnFillMode="RasterFill"   ;faster
res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
res@cnMissingValFillColor=0; white color for missing values

res@cnLevelSelectionMode = "ExplicitLevels"   ; set explict contour levels
res@cnLevels = (/1,11,25,37,39,50,100,200,254,255/)

res@lbLabelPosition = "Center"    ; label position
res@lbLabelAlignment = "BoxCenters"     ; label orientation
;res@lbLabelStrings =(/"0=missing data","1=no decision","11=night","25=no snow","37=lake","39=ocean","50=cloud","100=lake ice","200=snow","254=detector saturated","255=fill"/)
res@lbLabelStrings =(/"0","1","11","25","37","39","50","100","200","254","255"/)

res@lbTitleString =(/"0=missing data, 1=no decision, 11=night, 25=no snow, 37=lake, 39=ocean, 50=cloud, 100=lake ice, 200=snow, 254=detector saturated, 255=fill"/)
res@lbTitlePosition      = "Bottom"
res@lbTitleFontHeightF   = 0.0125

res@tiMainString = "MOD10_L2.A2000065.0040.005.2008235221207.hdf" ; create title
res@gsnLeftString="Field name: Snow_Cover"
res@gsnRightString="Units: none"

res@mpLimitMode = "LatLon"
res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
res@mpMaxLatF	= max(data@lat2d) ; 

res@gsnPolar="NH"; plot northern hemisphere
plot=gsn_csm_contour_map_polar(xwks,data,res)   ;Choose polar projection map

delete(plot) ; cleaning up resources used
delete(data)
delete(res)
delete(eos_file)
end


