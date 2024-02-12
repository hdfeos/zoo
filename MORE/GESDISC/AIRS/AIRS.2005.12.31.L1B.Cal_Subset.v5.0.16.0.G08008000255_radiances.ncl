;This example code illustrates how to access and visualize GESDISC_AIRS Swath in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).



load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 2-D swath file data field with 1 dimensional coordinates at various levels.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("AIRS.2005.12.31.L1B.Cal_Subset.v5.0.16.0.G08008000255.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

data=eos_file->radiances_L1B_AIRS_Cal_Subset(:,0) ; read specific subset of data field
; In order to read the radiances data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.
data@_FillValue=-9999

data_1=eos_file->radiances_L1B_AIRS_Cal_Subset(:,133) 
data_1@_FillValue=-9999

data_2=eos_file->radiances_L1B_AIRS_Cal_Subset(:,959) 
data_2@_FillValue=-9999

data_3=eos_file->radiances_L1B_AIRS_Cal_Subset(:,1338) 
data_3@_FillValue=-9999

data_4=eos_file->radiances_L1B_AIRS_Cal_Subset(:,2377) 
data_4@_FillValue=-9999

xwks=gsn_open_wks("pdf","AIRS.2005.12.31.L1B.Cal_Subset.v5.0.16.0.G08008000255_radiances") ; open workstation



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




res@cnLevelSelectionMode="ManualLevels" ; preset range defined to ensure uniform color legend across all levels
res@cnLevelSpacingF=10 ; set interval
res@cnMinLevelValF=0 ; set min and max values
res@cnMaxLevelValF=140 ; 

res@sfXArray = eos_file->Longitude_L1B_AIRS_Cal_Subset ; associate 1d longitude and latitude
res@sfYArray = eos_file->Latitude_L1B_AIRS_Cal_Subset ; 



gsn_define_colormap(xwks,"amwg") ; define colormap

plot=new(5, "graphic") ; allocate plot
res@tiMainString="AIRS.2005.12.31.L1B.Cal_Subset.v5.0.16.0.G08008000255.hdf" ; create title
res@gsnCenterString="radiances at Channel=0" ; create center text
plot(0)=gsn_csm_contour_map_ce(xwks,data,res)

delete(res@tiMainString) ; delete title for subsequent plots

res@gsnCenterString="radiances at Channel=133"
plot(1)=gsn_csm_contour_map_ce(xwks,data_1,res)

res@gsnCenterString="radiances at Channel=959"
plot(2)=gsn_csm_contour_map_ce(xwks,data_2,res)

res@gsnCenterString="radiances at Channel=1338"
plot(3)=gsn_csm_contour_map_ce(xwks,data_3,res)

res@gsnCenterString="radiances at Channel=2377"
plot(4)=gsn_csm_contour_map_ce(xwks,data_4,res)


delete(plot) ; cleaning up used variables
delete(data)
delete(data_1)
delete(data_2)
delete(data_3)
delete(data_4)
delete(res)
delete(eos_file)
end

