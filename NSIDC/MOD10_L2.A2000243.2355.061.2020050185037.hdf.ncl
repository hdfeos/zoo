; Copyright (C) 2020 by The HDF Group.
;   All rights reserved.
;
;  This example code illustrates how to access and visualize NSIDC MOD10
; L2 HDF-EOS2 Swath file in NCL.
;
;  If you have any questions, suggestions, comments on this example,
; please use the HDF-EOS Forum (http://hdfeos.org/forums).
;
;   If you would like to see an  example of any other NASA HDF/HDF-EOS
; data product that is not listed in the HDF-EOS Comprehensive Examples page
; (http://hdfeos.org/zoo), ;feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Tested under: NCL 6.6.2
; Last updated: 2020-04-10

begin
; Read file.
  file_name = "MOD10_L2.A2000243.2355.061.2020050185037.hdf"

; To read HDF-EOS2 files, .he2 is appended to the argument. 
; For more information, consult section 4.3.2 of
; http://hdfeos.org/software/ncl.php.
  eos_file = addfile(file_name+".he2", "r")
;  print(eos_file)
; Read data field, getting the clues about eos_file->Snow_Cover_MOD_Swath_Snow
; from print(eos_file)
  ; Swath dimension map is used.
  ; To match lat/lon size, subset data.
  data_byte=eos_file->NDSI_Snow_Cover_MOD_Swath_Snow(::10,::10)
  printVarSummary(data_byte)
  data = tounsigned(data_byte)
;  print(stddev(data))
;  print(variance(data))
;  print(get_unique_values(data))
  uniq_years = get_unique_values(data)
  nuniq      = dimsizes(uniq_years)

  do i=0,nuniq-1
    print("Year " + uniq_years(i) + " appears in the array " + \
          num(data.eq.uniq_years(i)) + " times.")
  end do  
  dimsize=dimsizes(data)
  nlon=dimsize(0)  ;4060 (from datafield in hdf file)
  nlat=dimsize(1)  ;2708 (from datafield in hdf file)

; We need to use eosdump to generate lat and lon
; For information on how to obtain the lat/lon data, check this URL
; http://hdfeos.org/zoo/note_non_geographic.php

; To properly display the data, the latitude/longitude must be remapped.
  lat=eos_file->Latitude_MOD_Swath_Snow
  lon=eos_file->Longitude_MOD_Swath_Snow
  printVarSummary(lat)
  printVarSummary(lon)  
  data@lat2d=lat
  data@lon2d=lon

  xwks=gsn_open_wks("png", file_name+".ncl")    ; open workstation
  gsn_define_colormap(xwks,"amwg")

  setvalues NhlGetWorkspaceObjectId() ; make maximum filesize larger
  "wsMaximumSize" : 200000000
  end setvalues

  res=True 
  res@cnFillOn=True   
  res@gsnMaximize=True
  res@gsnPaperOrientation = "portrait"  
  res@cnLinesOn=False
  res@cnLineLabelsOn =  False 
  res@gsnSpreadColors=True 
  res@cnFillMode="RasterFill" 
  res@cnMissingValFillPattern = 0 
  res@cnMissingValFillColor=0

  res@cnLevelSelectionMode = "ExplicitLevels"   ; set explict contour levels
  res@cnLevels = (/0,200,238,249,250/)
  ; res@cnFillColors = (/"Green", "Yellow", "Orange", "White", "Purple", "Blue"/)
  res@cnFillColors = (/"Green", "Yellow", "Orange", "Red", "Purple", "Blue"/)
  res@lbLabelPosition = "Center"    ; label position
  res@lbLabelAlignment = "BoxCenters"     ; label orientation
  res@lbLabelStrings =(/"night","inland water"/)
  res@lbTitlePosition      = "Bottom"
  res@lbTitleFontHeightF   = 0.0125

  res@tiMainString = file_name
  res@mpLimitMode = "LatLon"
; Set limits of map based on the min/max of the dataset latitude/longitude.
  res@mpMinLatF	= min(data@lat2d)
  res@mpMaxLatF	= max(data@lat2d)
; Plot northern hemisphere.
  res@gsnPolar="NH"
; Choose polar projection map.
  plot=gsn_csm_contour_map_polar(xwks,data,res)  
end


