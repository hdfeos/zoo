;This example code illustrates how to access and visualize LaRC_CERES HDF4 file in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 3-D data field at various levels.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin

  eos_file = addfile("CERES_EBAF_TOA_Terra_Edition1A_200003-200510.nc.hdf", "r") ; Read file. 

; read specific subset of data field and associate longitude and latitude
  data = eos_file->netclr(0,:,:) 
  data@lat1d = eos_file->lat;
  data@lon1d = eos_file->lon; 

; read specific subset of data field and associate longitude and latitude
  data_1 = eos_file->netclr(26,:,:)
  data_1@lat1d = eos_file->lat;
  data_1@lon1d = eos_file->lon; 

; read specific subset of data field and associate longitude and latitude
  data_2 = eos_file->netclr(35,:,:)
  data_2@lat1d = eos_file->lat; 
  data_2@lon1d = eos_file->lon; 

; read specific subset of data field and associate longitude and latitude
  data_3 = eos_file->netclr(66,:,:)
  data_3@lat1d = eos_file->lat; 
  data_3@lon1d = eos_file->lon; 

  xwks = gsn_open_wks("pdf","CERES_EBAF_TOA_Terra_Edition1A_200003-200510.nc_netclr") ; open workstation

  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True ; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn=False ; turn off contour lines
  res@cnLineLabelsOn = False ; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@lbOrientation = "vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0; white color for missing values
  res@lbLabelAutoStride = True ; ensure no label overlap 

  res@gsnLeftStringFontHeightF=10 ; make text smaller
  res@gsnCenterStringFontHeightF=10
  res@gsnRightStringFontHeightF=10

  res@cnLevelSelectionMode="ManualLevels" ; preset range defined to ensure uniform color legend across all levels
  res@cnLevelSpacingF=25 ; set interval
  res@cnMinLevelValF=-225 ; set min and max values
  res@cnMaxLevelValF=125 ;

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  res@tiMainString="CERES_EBAF_TOA_Terra_Edition1A_200003-200510.nc.hdf" ; create title
  plot=new(4, "graphic") ; allocate plot
  res@gsnCenterString="netclr at time=0" ; create center text
  plot(0)=gsn_csm_contour_map_ce(xwks,data,res) ; 
  delete(res@tiMainString) ; delete title for subsequent plots

  res@gsnCenterString="netclr at time=26" ; create center text
  plot(1)=gsn_csm_contour_map_ce(xwks,data_1,res) ; 

  res@gsnCenterString="netclr at time=35"
  plot(2)=gsn_csm_contour_map_ce(xwks,data_2,res)

  res@gsnCenterString="netclr at time=66"
  plot(3)=gsn_csm_contour_map_ce(xwks,data_3,res)

; cleaning up resources used
  delete(plot) 
  delete(xwks)
  delete(data)
  delete(data_1)
  delete(data_2)
  delete(data_3)
  delete(res)
  delete(eos_file)

end