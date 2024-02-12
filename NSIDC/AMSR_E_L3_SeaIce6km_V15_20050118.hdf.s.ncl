;
;  This example code illustrates how to access and visualize NSIDC AMSR_E L3
; Sea Ice 6km HDF-EOS2 Grid file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please use
; the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.6.2
; Last updated: 2022-02-04
begin
  file_name = "AMSR_E_L3_SeaIce6km_V15_20050118.hdf"
  
  eos_file = addfile(file_name+".he2", "r")

  data_raw = eos_file->SI_06km_SH_89V_DAY_SpPolarGrid06km(:,:) ; read data field
  ; printVarSummary(data_raw)

; Multiply scale by 0.1 to get Kelvin according to [1].

  data = data_raw * 0.1
  
; Associate longitude and latitude.
  data@lon2d = eos_file->GridLon_SpPolarGrid06km
  data@lat2d = eos_file->GridLat_SpPolarGrid06km
  
; Making this double assignment allows the _FillValue of 0 to be properly
; represented.
  data@_FillValue = 0h 
  data@_FillValue = -9999h ; 'h' is appended to avoid type mismatching.

  xwks = gsn_open_wks("png", file_name+".s.ncl") ; open workstation

  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn =  False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@lbOrientation = "vertical" ;vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0; white color for missing values

  res@gsnPolar = "SH" ; plot northern hemisphere

  res@mpMaxLatF = max(data@lat2d) ; ignore the area outside of the maximum latitude

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
  res@tiMainString = file_name ; create title
  data@long_name = data_raw@hdfeos_name
  data@units ="K"

  plot = gsn_csm_contour_map(xwks,data,res) ; create plot
end

; References
;
; [1] https://nsidc.org/data/AE_SI6