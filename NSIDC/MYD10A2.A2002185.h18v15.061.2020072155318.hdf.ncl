; Copyright (C) 2020 by The HDF Group.
;   All rights reserved.
;
;  This example code illustrates how to access and visualize NSIDC MYD10A2
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
; $ncl MYD10A2.A2002185.h18v15.061.2020072155318.hdf.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2020-04-13

begin
; Read file.
; To read HDF-EOS2 files, .he2 is appended to the argument. 
; For more information, consult section 4.3.2 of [1]
  file_name = "MYD10A2.A2002185.h18v15.061.2020072155318.hdf"
  eos_file = addfile(file_name+".he2", "r")
  
  print(eos_file)
  data_byte = eos_file->Maximum_Snow_Extent_MOD_Grid_Snow_500m
  
; Only _FillValue attribute will be copied.
  data = tounsigned(eos_file->Maximum_Snow_Extent_MOD_Grid_Snow_500m)

; Copy other attributes.
  data@long_name = data_byte@long_name
  data@units = data_byte@units
  delete(data@_FillValue)


; To properly display the data, the latitude/longitude must be remapped.
  data@lat2d = eos_file->GridLat_MOD_Grid_Snow_500m
  lon = eos_file->GridLon_MOD_Grid_Snow_500m
  lon = where(lon.gt.0, lon, lon+360)  
  data@lon2d = lon


  xwks = gsn_open_wks("png", file_name+".ncl") ; open workstation
  gsn_define_colormap(xwks,"amwg")

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
  res@gsnRightStringFontHeightF = 13 ; make font smaller
  res@cnLevels = (/238,254/)  
  res@cnLevelSelectionMode = "ExplicitLevels" ; set explict contour levels
  res@lbLabelPosition = "Center" ; label position
  res@lbLabelAlignment = "BoxCenters" ; label orientation
  res@lbLabelStrings = (/"0","239","255"/)
  res@lbTitleString = (/"0=missing, 239=ocean,255=fill"/)
  res@lbTitlePosition  = "Bottom"
  res@lbTitleFontHeightF = 0.0125
  res@tiMainString = file_name
  res@trGridType = "TriangularMesh" 
  
; Set limits of map, based on the min/max of the dataset latitude/longitude  
  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d-20) 
  res@mpMaxLatF	= max(data@lat2d+20)  
  res@mpMinLonF	= min(data@lon2d) 
  res@mpMaxLonF	= max(data@lon2d)
  res@mpCenterLonF = 180.0  
  plot = gsn_csm_contour_map_ce(xwks,data,res) ; create plot
end

; References
;
; [1] http://hdfeos.org/software/ncl.php