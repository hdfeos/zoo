;This example code illustrates how to access and visualize LaRC_MOPITT Grid file in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 3-D grid file data field at various levels.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

 begin

  eos_file=addfile("MOP03-20000303-L3V1.0.1.hdf.he2", "r") ; Read file. 

  data=eos_file->CO_Profiles_Day_MOP03(:,:,0) ;read data field
  data@lat1d=eos_file->Latitude_MOP03;
  data@lon1d=eos_file->Longitude_MOP03;
  data@_FillValue=-9999;

  data_1=eos_file->CO_Profiles_Day_MOP03(:,:,2) ;read data field
  data_1@lat1d=eos_file->Latitude_MOP03;
  data_1@lon1d=eos_file->Longitude_MOP03;
  data_1@_FillValue=-9999;

  data_2=eos_file->CO_Profiles_Day_MOP03(:,:,4) ;read data field
  data_2@lat1d=eos_file->Latitude_MOP03;
  data_2@lon1d=eos_file->Longitude_MOP03;
  data_2@_FillValue=-9999;

  data_3=eos_file->CO_Profiles_Day_MOP03(:,:,6) ;read data field
  data_3@lat1d=eos_file->Latitude_MOP03;
  data_3@lon1d=eos_file->Longitude_MOP03;
  data_3@_FillValue=-9999;

  xwks=gsn_open_wks("pdf","MOP03-20000303-L3V1.0.1_CO_Profiles_Day.ncl") ; open workstation

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
  res@lbLabelAutoStride = True ; ensure no label overlap
; res@gsnLeftStringFontHeightF=15 ; make text smaller
  res@gsnCenterStringFontHeightF=15
  res@gsnRightStringFontHeightF=15

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  res@cnLevelSelectionMode="ManualLevels" ; preset range defined to ensure uniform color legend across all levels
  res@cnLevelSpacingF=20 ; set interval
  res@cnMinLevelValF=0 ; set min and max values
  res@cnMaxLevelValF=440 ;

  res@tiMainString="MOP03-20000303-L3V1.0.1.hdf" ; create title
  plot=new(4, "graphic")

  res@gsnCenterString="CO_Profiles_Day at nprs=0" ; create center text
; Unit is ppbv according to spec. It's not in file itself. 
; See spec at http://www.acd.ucar.edu/mopitt/file-spec.shtml#L2
  res@gsnRightString = "Units: ppbv" ; create right text
  plot(0)=gsn_csm_contour_map(xwks,data,res) ; 
  delete(res@tiMainString)

  res@gsnCenterString="CO_Profiles_Day at nprs=2" ; create center text
; Unit is ppbv according to spec. It's not in file itself. 
; See spec at http://www.acd.ucar.edu/mopitt/file-spec.shtml#L2
  res@gsnRightString = "Units: ppbv" ; create right text
  plot(0)=gsn_csm_contour_map(xwks,data_1,res) ; 

  res@gsnCenterString="CO_Profiles_Day at nprs=4" ; create center text
; Unit is ppbv according to spec. It's not in file itself. 
; See spec at http://www.acd.ucar.edu/mopitt/file-spec.shtml#L2
  res@gsnRightString = "Units: ppbv" ; create right text
  plot(0)=gsn_csm_contour_map(xwks,data_2,res) ; 

  res@gsnCenterString="CO_Profiles_Day at nprs=6" ; create center text
; Unit is ppbv according to spec. It's not in file itself. 
; See spec at http://www.acd.ucar.edu/mopitt/file-spec.shtml#L2
  res@gsnRightString = "Units: ppbv" ; create right text
  plot(0)=gsn_csm_contour_map(xwks,data_3,res) ; 

  delete(plot) ; cleaning up resources used
  delete(xwks)
  delete(data)
  delete(data_1)
  delete(data_2)
  delete(data_3)
  delete(res)
  delete(eos_file)

end