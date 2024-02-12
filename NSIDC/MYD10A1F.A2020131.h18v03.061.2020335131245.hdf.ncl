;
;  This example code illustrates how to access and visualize NSIDC MYD10A1F
; L3 HDF-EOS2 Sinusoidal Grid file in NCL.
;
;  If you have any questions, suggestions, comments on this example,
; please use the HDF-EOS Forum (http://hdfeos.org/forums).
;
;   If you would like to see an  example of any other NASA HDF/HDF-EOS
; data product that is not listed in the HDF-EOS Comprehensive Examples page
; (http://hdfeos.org/zoo), ;feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
;
; Usage:save this script and run 
; 
; $ncl MYD10A1F.A2020131.h18v03.061.2020335131245.hdf.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2020-12-03

begin
; Read file.
; To read HDF-EOS2 files, .he2 is appended to the argument. 
; For more information, consult section 4.3.2 of [1]
  file_name = "MYD10A1F.A2020131.h18v03.061.2020335131245.hdf"  
  eos_file = addfile(file_name+".he2", "r")
  
;  print(eos_file)

  data_byte = eos_file->MYD10A1_NDSI_Snow_Cover_MOD_Grid_Snow_500m
  
; Only _FillValue attribute will be copied.
  data = tounsigned(eos_file->MYD10A1_NDSI_Snow_Cover_MOD_Grid_Snow_500m)
;  printVarSummary(data)
;  print(isubyte(data))
;  print(isunsigned(data))

; Copy other attributes.
  data@long_name = data_byte@long_name
  delete(data@_FillValue)


; To properly display the data, the latitude/longitude must be remapped.
  data@lat2d = eos_file->GridLat_MOD_Grid_Snow_500m
  lon = eos_file->GridLon_MOD_Grid_Snow_500m
  data@lon2d = lon


  xwks = gsn_open_wks("png", file_name+".ncl") ; open workstation
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")
  setvalues NhlGetWorkspaceObjectId() ; make maximum filesize larger
  "wsMaximumSize" : 200000000
  end setvalues

  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True ; make plot large
  res@gsnPaperOrientation = "portrait" ; force prtrait orientation
  res@cnLinesOn = False ;turn off contour line
  res@cnLineLabelsOn = False ; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0 ; white color for missing values
  res@gsnLeftStringFontHeightF = 13 ; make font smaller
  res@cnLevels = (/101,201,202,212,238,240,251,255/)  
  res@cnLevelSelectionMode = "ExplicitLevels" ; set explict contour levels
  res@lbLabelPosition = "Center" ; label position
  res@lbLabelAlignment = "BoxCenters" ; label orientation
  res@lbLabelStrings = (/"0-100","200","201","211","237","239","250","254","255"/)
  res@lbTitleString = (/"0-100=NDSI snow, 200=missing data, 201=no decision, 211=night, 237=inland water, 239=ocean, 250=cloud, 254=detector saturated, 255=fill"/)
  res@lbTitlePosition  = "Bottom"
  res@lbTitleFontHeightF = 0.0125
  res@tiMainString = file_name
  res@trGridType = "TriangularMesh" 
  
; Set limits of map, based on the min/max of the dataset latitude/longitude  
  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d-20) 
  res@mpMaxLatF	= max(data@lat2d+20)  
  res@mpMinLonF	= min(data@lon2d-20) 
  res@mpMaxLonF	= max(data@lon2d+20)
  plot = gsn_csm_contour_map_ce(xwks, data, res) ; create plot
end

; References
;
; [1] http://hdfeos.org/software/ncl.php