;
;  This example code illustrates how to access and visualize AMSR-E Monthly Rain
; L3 HDF-EOS2 Grid file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage:
;
;   $ncl AMSR_E_L3_RainGrid_V06_200206.hdf.ncl
;
; Tested under: NCL 6.5.0
; Last updated: 2018-12-10

begin
; Open file.
; To read the file as HDF-EOS2 file, .he2 is appended to the argument. 
; For more information, consult section 4.3.2 of
; http://hdfeos.org/software/ncl.php.
  file_name = "AMSR_E_L3_RainGrid_V06_200206.hdf";  
  eos_file = addfile(file_name+".he2", "r")

  data = eos_file->TbOceanRain_MonthlyRainTotal_GeoGrid(:,:)
  printVarSummary(data)  
  data@_FillValue = -1

; Use hard-coded unit mm according to 
; https://nsidc.org/data/ae_rngd
  data@units = "mm"

  xwks = gsn_open_wks("png", file_name+".ncl") ; open workstation

  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True ; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn = False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@lbOrientation = "vertical" ;vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0; white color for missing values

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
  res@tiMainString = file_name
  plot = gsn_csm_contour_map_ce(xwks,data,res) ; create plot
end