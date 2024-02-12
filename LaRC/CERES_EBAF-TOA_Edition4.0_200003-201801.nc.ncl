;
;  This example code illustrates how to access and visualize LaRC CERES EBAF TOA
; Edition 4.0 netCDF-3 Grid file in NCL.
;
;  If you have any questions, suggestions, comments on this example, please use
; the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage:save this script and run 
;
; $ncl CERES_EBAF_TOA_Terra_Edition1A_200003-200510.nc.ncl
;
; Tested under: NCL 6.4.0
; Last updated: 2018-06-25

begin
; Read file.
  file_name = "CERES_EBAF-TOA_Edition4.0_200003-201801.nc"
  eos_file = addfile(file_name, "r")
  
; List file content.
;  print(eos_file)
  
; read specific subset of data field and associate longitude and latitude
  data = eos_file->toa_net_clr_mon(0,:,:) 
  data@long_name =   data@long_name+" at time=0"

  xwks = gsn_open_wks("png", file_name+".ncl") ; open workstation

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
  res@gsnRightStringFontHeightF=10
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap
  ; Create title.
  res@tiMainString=file_name 
  plot=new(4, "graphic") ; allocate plot
  plot=gsn_csm_contour_map_ce(xwks,data,res) ; 
end