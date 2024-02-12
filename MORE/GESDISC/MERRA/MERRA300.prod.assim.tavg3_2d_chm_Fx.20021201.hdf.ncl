;
;  This example code illustrates how to access and visualize GES DISC MERRA
; L3 HDF4 file in NCL.
;
;  If you have any questions, suggestions, comments  on this example, please
; use the HDF-EOS Forum (http://hdfeos.org/forums).
;
;  If you would like to see an example of any other NASA HDF/HDF-EOS data
; product that is not listed in the HDF-EOS Comprehensive Examples page
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Usage:save this script and run
;
; $ncl MERRA300.prod.assim.tavg3_2d_chm_Fx.20021201.hdf.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2020-10-19


begin
  file_name = "MERRA300.prod.assim.tavg3_2d_chm_Fx.20021201.hdf"
  
  ; Read as an HDF-EOS2 file.
  eos_file=addfile(file_name+".he2", "r")

  ; Read specific subset of data field.
  data=eos_file->PRECANV_EOSGRID(1,:,:)
  data_1=eos_file->PRECANV_EOSGRID(2,:,:) 
  data_2=eos_file->PRECANV_EOSGRID(4,:,:)
  data_3=eos_file->PRECANV_EOSGRID(5,:,:)
  data_4=eos_file->PRECANV_EOSGRID(7,:,:)

  xwks=gsn_open_wks("png", file_name+".ncl") ; open workstation 

  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@cnLinesOn=False ; turn off contour lines
  res@gsnMaximize=True ; use entire page
  res@gsnPaperOrientation="Portrait" ; force portrait
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbLabelAutoStride=True ; ensure labels do not overlap
  res@lbOrientation="vertical" ; vertical labels
  res@cnMissingValFillPattern=0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0; white color for missing values
  res@gsnLeftStringFontHeightF=10 ; make text smaller
  res@gsnCenterStringFontHeightF=10
  res@gsnRightStringFontHeightF=10

  res@cnLevelSelectionMode="ManualLevels" ; preset range defined to ensure uniform color legend across all levels
  res@cnLevelSpacingF=2.5e-05 ; set interval
  res@cnMinLevelValF=2.5e-05 ; set min and max values
  res@cnMaxLevelValF=.000375 ;
  
  maximize_output(xwks, res);
  
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  plot=new(5, graphic) ; allocate plot
  res@tiMainString=file_name

  res@gsnCenterString="at TIME=1" ; create center text
  plot(0)=gsn_csm_contour_map_ce(xwks, data, res) 

  delete(res@tiMainString) ; delete title for subsequent plots

  res@gsnCenterString="at TIME=2"
  plot(1)=gsn_csm_contour_map_ce(xwks, data_1, res) 

  res@gsnCenterString="at TIME=4"
  plot(2)=gsn_csm_contour_map_ce(xwks, data_2, res) 

  res@gsnCenterString="at TIME=5"
  plot(3)=gsn_csm_contour_map_ce(xwks, data_3, res) 

  res@gsnCenterString="at TIME=7"
  plot(4)=gsn_csm_contour_map_ce(xwks, data_4, res)
  
  gsn_panel(xwks, plot, (/5,1/), False)
end
