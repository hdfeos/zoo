;
;  This example code illustrates how to access and visualize GES DISC MERRA
; HDF-EOS2 L3 Grid file in NCL.
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
; $ncl MERRA300.prod.assim.tavg3_3d_chm_Ne.20021201.hdf.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2020-10-23

begin
  file_name="MERRA300.prod.assim.inst3_3d_chm_Ne.20021201.hdf"
  
  ; Read as an HDF-EOS2 file.    
  eos_file=addfile(file_name+".he2", "r")
  
  ; Subset data.
  data=eos_file->PLE_EOSGRID(1,72,:,:)
  data_1=eos_file->PLE_EOSGRID(2,50,:,:)
  data_2=eos_file->PLE_EOSGRID(4,42,:,:)
  data_3=eos_file->PLE_EOSGRID(5,46,:,:)
  data_4=eos_file->PLE_EOSGRID(7,70,:,:)

  xwks=gsn_open_wks("png", file_name+".ncl")  

  res=True
  
  res@cnFillMode="RasterFill"  
  res@cnFillOn=True
  res@cnLevelSelectionMode="ManualLevels"
  res@cnLevelSpacingF=2500
  res@cnLinesOn=False
  res@cnMinLevelValF=20000
  res@cnMaxLevelValF=105000
  res@cnMissingValFillPattern=0
  res@cnMissingValFillColor=0

  res@gsnLeftStringFontHeightF=15
  res@gsnCenterStringFontHeightF=15
  res@gsnRightStringFontHeightF=15
  res@gsnSpreadColors=True
  
  res@lbLabelAutoStride=True
  res@lbOrientation="vertical"

  
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

  plot=new(5, graphic)

  res@tiMainString=file_name

  res@gsnCenterString="PLE at TIME=1, Height=72"
  plot(0)=gsn_csm_contour_map_ce(xwks,data,res) 
  delete(res@tiMainString)


  res@gsnCenterString="PLE at TIME=2, Height=50"
  plot(1)=gsn_csm_contour_map_ce(xwks,data_1,res) 

  res@gsnCenterString="PLE at TIME=4, Height=42"
  plot(2)=gsn_csm_contour_map_ce(xwks,data_2,res) 

  res@gsnCenterString="PLE at TIME=5, Height=46"
  plot(3)=gsn_csm_contour_map_ce(xwks,data_3,res) 

  res@gsnCenterString="PLE at TIME=7, Height=70"
  plot(4)=gsn_csm_contour_map_ce(xwks,data_4,res)
  
  ; Create a panel with 3 rows 2 columns.
  gsn_panel(xwks, plot, (/3,2/), False)    
end