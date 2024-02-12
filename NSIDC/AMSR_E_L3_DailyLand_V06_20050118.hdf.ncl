;
;  This example code illustrates how to access and visualize NSIDC AMSR_E L3 
; Daily Land HDF-EOS2 Grid file in NCL.
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
; $ncl AMSR_E_L3_DailyLand_V06_20050118.hdf.ncl
;
; Tested under: NCL 6.5.0
; Last updated: 2018-10-16

begin
  file_name = "AMSR_E_L3_DailyLand_V06_20050118.hdf"
; Read file.   
; To read HDF-EOS2 files, .he2 is appended to the argument.
; For more information, consult section 4.3.2 of [1].
  eos_file=addfile(file_name+".he2", "r")

; Read data field.
  data_raw=eos_file->A_TB36_5H__Res_1__Ascending_Land_Grid(:,:) 

; Multiply scale by 0.1 to get Kelvin according to [2].
  data=data_raw*0.1
  
; Associate longitude and latitude.
  data@lon2d=eos_file->GridLon_Ascending_Land_Grid
  data@lat2d=eos_file->GridLat_Ascending_Land_Grid
  
  data@long_name = "A_TB36.5H (Res 1)"
  data@units = "K"
  
  xwks = gsn_open_wks("png", file_name+".ncl") ; open workstation.

  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@gsnMaximize=True; make plot large
  res@gsnPaperOrientation="portrait" ; force portrait orientation
  res@cnLinesOn=False ; turn off contour lines
  res@cnLineLabelsOn=  False; turn off contour line labels
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbOrientation="vertical" ;vertical labels
  res@mpProjection = "CylindricalEqualArea" ; change map projection 
  res@tiMainString = file_name
  
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
  plot=gsn_csm_contour_map(xwks,data,res) ; create plot
end

; References
;
; [1] http://hdfeos.org/software/ncl.php.
; [2] https://nsidc.org/data/ae_land3