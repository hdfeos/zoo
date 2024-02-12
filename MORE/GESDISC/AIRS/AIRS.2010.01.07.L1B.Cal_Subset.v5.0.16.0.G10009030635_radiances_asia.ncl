;This example code illustrates how to access and visualize GESDISC_AIRS Swath in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).



load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 2-D swath file data field with 1 dimensional coordinates at one specific level and location.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.


begin
eos_file=addfile("AIRS.2010.01.07.L1B.Cal_Subset.v5.0.16.0.G10009030635.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

data=eos_file->radiances_L1B_AIRS_Cal_Subset(:,996) ; read specific subset of data field
; In order to read the radiances data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

data@_FillValue= -9999 


xwks=gsn_open_wks("pdf","AIRS.2010.01.07.L1B.Cal_Subset.v5.0.16.0.G10009030635_radiances_asia") ; open workstation

res=True ; plot mods desired
res@cnFillOn=True ; enable contour fill
res@gsnMaximize=True ; maximize plot on the page
res@gsnPaperOrientation="portrait" ; portrait orientation
res@cnLinesOn=False ; turn off contour lines
res@gsnSpreadColors=True ; use the entire color spectrum
res@cnFillMode="RasterFill" ; faster
res@lbLabelAutoStride=True ; ensure labels do not overlap
res@lbOrientation = "vertical" ; vertical labels
res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
res@cnMissingValFillColor=0; white color for missing values

res@sfXArray = eos_file->Longitude_L1B_AIRS_Cal_Subset ; associate 1d longitude and latitude 
res@sfYArray = eos_file->Latitude_L1B_AIRS_Cal_Subset

res@mpLimitMode="LatLon" ; limit map by latitude/longitude
 
res@mpMinLatF=0; only plot latitudes above 0 degrees
res@mpMinLonF=60; only plot longitudes above 60 degrees



gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

res@tiMainString="AIRS.2010.01.07.L1B.Cal_Subset.v5.0.16.0.G10009030635.hdf" ; create title
res@gsnCenterString="radiances at Channel=996, Asia only"
plot=gsn_csm_contour_map_ce(xwks,data,res) ; create plot

delete(plot) ; cleaning up used resources
delete(data)
delete(res)
delete(eos_file)
end




