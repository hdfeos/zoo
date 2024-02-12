;  This example code illustrates how to access and visualize OBPG SeaWiFS
;  Grid HDF4 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.0.0
; Last updated: 2011-11-07

; Please make sure that you have the .hluresfile in your home directory 
; so that you won't get any PLCHHQ error messages. See [1] for details.


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"


; This is an example of a 2-D data field.
; It is assumed users know how to obtain information such as _FillValue 
; using HDFView.
; For information about HDFView, visit [2]. 

begin

; This is not an HDF-EOS2 file.
; For more information, consult section 4.3.2 of [3].
; Read file. 
file_name = "S1999001.L3m_DAY_CHL_chlor_a_9km.hdf"
hdf4_file=addfile(file_name, "r") 

; Read data field.
data_signed=hdf4_file->l3m_data

; Set fill value.
data_signed@_FillValue=data_signed@Fill

; Set offset.
theIntercept=data_signed@Intercept 

; Set scale.
theSlope=data_signed@Slope

; From the hdf file, we can see hdf4_file->l3m_data is 32-bit floating-point,
; so cannot use short2flt() to implicitly use Slope and Intercept
data=theIntercept+data_signed*theSlope

; This file does not contain geolocation fields. 
; To properly display the data, the latitude/longitude must be remapped from 
; its metadata.
; See [4] for more information.
data!0="lat" 
data!1="lon" 

nLat=hdf4_file@Number_of_Lines ;2160
nLon=hdf4_file@Number_of_Columns ;4320

latStep=hdf4_file@Latitude_Step ;0.083333336
lonStep=hdf4_file@Longitude_Step ;0.083333336

latStartpoint=hdf4_file@SW_Point_Latitude ;-89.958336
lonStartpoint=hdf4_file@SW_Point_Longitude ;-179.95833

; See [5] for ispan().
lat=ispan(0,nLat-1,1)*latStep+latStartpoint
lon=ispan(0,nLon-1,1)*lonStep+lonStartpoint


lat@units  = "degrees_north" 
lon@units  = "degrees_east"  

; Use north-to-south latitude ordering.
lat=lat(::-1) 

data&lat=lat
data&lon=lon

; Apply log for displaying image. See [6] for details.
data2 = log(data)

; Open workstation.
xwks=gsn_open_wks("pdf", file_name+".ncl")

setvalues NhlGetWorkspaceObjectId() ; make maximum filesize larger
"wsMaximumSize" : 200000000
end setvalues

res=True ; plot mods desired
res@cnFillOn=True ; enable contour fill
res@cnLinesOn=False ; turn off contour lines
res@gsnSpreadColors=True ; use the entire color spectrum
res@cnFillMode="RasterFill" ; faster
res@lbLabelAutoStride=True ; ensure labels do not overlap
res@lbOrientation = "vertical" ; vertical labels
res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
res@cnMissingValFillColor=0; white color for missing values


gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

res@tiMainString = file_name

data@long_name = hdf4_file@Parameter
data@units =  hdf4_file@Units
plot=gsn_csm_contour_map_ce(xwks,data,res) 

data2!0="lat" 
data2!1="lon" 
data2&lat = lat
data2&lon = lon
data2@units = hdf4_file@Units
data2@long_name = hdf4_file@Parameter + " (log scale)"
plot=gsn_csm_contour_map_ce(xwks,data2,res) 

delete(plot) ; cleaning up resources used
delete(res)
delete(xwks)
delete(lat)
delete(lon)
delete(data)
delete(hdf4_file)
end

; References
;
; [1] http://www.ncl.ucar.edu/Document/Graphics/hlures.shtml
; [2] http://www.hdfgroup.org/hdf-java-html/hdfview/
; [3] http://hdfeos.org/software/ncl.php
; [4] http://www.ncl.ucar.edu/Applications/Scripts/regrid_10.ncl
; [5] http://www.ncl.ucar.edu/Document/Functions/Built-in/ispan.shtml
; [6] http://oceancolor.gsfc.nasa.gov/DOCS/Ocean_Level-3_SMI_Products.pdf