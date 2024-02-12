;
;  This example code illustrates how to access and visualize GESDISC TRMM
; version 7 HDF4 Level 2 2A12 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.1.2
; Last updated: 2014-4-1

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
begin

; Read file. 
file_name = "2A12.20140308.92894.7.HDF"
hdf4_file=addfile(file_name, "r") 

; Print metadata information.
print(hdf4_file)

; Read data to plot.
data=hdf4_file->surfaceRain

; Read lat/lon data.
longitude=hdf4_file->Longitude
latitude=hdf4_file->Latitude

; Correct units to follow the CF conventions.
; In the HDF4 file, the attribute values are "degrees". 
longitude@units = "degrees_east"
latitude@units = "degrees_north"

data@lon2d=longitude
data@lat2d=latitude

xwks=gsn_open_wks("png",file_name+".ncl")

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
res@cnMissingValFillColor=0; white color for missing values
; Without the following, it will take a very long time to plot.
res@trGridType = "TriangularMesh" 
res@cnLevelSelectionMode="ExplicitLevels";
res@cnLevels=(/0, 0.1, 1.0, 10.0, 30.0/)
gsn_define_colormap(xwks,"wh-bl-gr-ye-re") ; define colormap

res@tiMainString=file_name ; create title
plot=gsn_csm_contour_map_ce(xwks,data,res)
delete(plot) ; cleaning up resources used
delete(data)
delete(xwks)
delete(res)

delete(hdf4_file)
end

; References
; [1] http://disc.sci.gsfc.nasa.gov/precipitation/documentation/TRMM_README/TRMM_2A12_readme.shtml


