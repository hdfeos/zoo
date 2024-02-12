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
; $ncl MERRA300.prod.assim.tavg3_3d_chm_Fv.20021201.hdf.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2020-10-19

begin
  file_name="MERRA300.prod.assim.tavg3_3d_chm_Fv.20021201.hdf"
  ; Read as an HDF-EOS2 file.
  eos_file=addfile(file_name+".he2", "r")
  data=eos_file->DQRLSC_EOSGRID(1,:,:)
  data_1=eos_file->DQRLSC_EOSGRID(2,:,:)
  data_2=eos_file->DQRLSC_EOSGRID(4,:,:)
  data_3=eos_file->DQRLSC_EOSGRID(5,:,:)
  data_4=eos_file->DQRLSC_EOSGRID(7,:,:)

  xwks=gsn_open_wks("png", file_name+".ncl")

  res=True
  
  res@cnFillMode="RasterFill"    
  res@cnFillOn=True
  res@cnLevelSelectionMode="ManualLevels"
  res@cnLevelSpacingF=.0001
  res@cnLinesOn=False
  res@cnMaxLevelValF=.002  
  res@cnMinLevelValF=.0001
  res@cnMissingValFillPattern=0
  res@cnMissingValFillColor=0
  
  res@gsnCenterStringFontHeightF=10
  res@gsnLeftStringFontHeightF=10
  res@gsnRightStringFontHeightF=10
  res@gsnSpreadColors=True
  
  res@lbLabelAutoStride=True
  res@lbOrientation = "vertical"

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

  plot=new(5, graphic)
  
  res@tiMainString="MERRA300.prod.assim.tavg3_3d_chm_Fv.20021201.hdf"
  res@gsnCenterString="DQRLSC at TIME=1"
  plot(0)=gsn_csm_contour_map_ce(xwks,data,res) 
  delete(res@tiMainString) 

  res@gsnCenterString="DQRLSC at TIME=2"
  plot(1)=gsn_csm_contour_map_ce(xwks,data_1,res) 

  res@gsnCenterString="DQRLSC at TIME=4"
  plot(2)=gsn_csm_contour_map_ce(xwks,data_2,res) 

  res@gsnCenterString="DQRLSC at TIME=5"
  plot(3)=gsn_csm_contour_map_ce(xwks,data_3,res) 

  res@gsnCenterString="DQRLSC at TIME=7"
  plot(4)=gsn_csm_contour_map_ce(xwks,data_4,res)
  
  gsn_panel(xwks, plot, (/3,2/), False)  
end
