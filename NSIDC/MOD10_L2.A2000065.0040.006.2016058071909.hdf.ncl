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
; Tested under: NCL 6.5.0
; Last updated: 2018-12-19

begin
; Read file.
  file_name = "MOD10_L2.A2000065.0040.006.2016058071909.hdf"

; To read HDF-EOS2 files, .he2 is appended to the argument. 
; For more information, consult section 4.3.2 of
; http://hdfeos.org/software/ncl.php.
  eos_file = addfile(file_name+".he2", "r")
;  print(eos_file)
; Read data field, getting the clues about eos_file->Snow_Cover_MOD_Swath_Snow
; from print(eos_file)
  
  data_byte=eos_file->NDSI_Snow_Cover_MOD_Swath_Snow 
  data = tounsigned(data_byte)
  dimsize=dimsizes(data)
  nlon=dimsize(0)  ;4060 (from datafield in hdf file)
  nlat=dimsize(1)  ;2708 (from datafield in hdf file)

; We need to use eosdump to generate lat and lon
; For information on how to obtain the lat/lon data, check this URL
; http://hdfeos.org/zoo/note_non_geographic.php

; To properly display the data, the latitude/longitude must be remapped.
  lat=asciiread("lat_MOD10_L2.A2000065.0040.006.2016058071909.output", (/nlon,nlat/),"float")
  lon=asciiread("lon_MOD10_L2.A2000065.0040.006.2016058071909.output", (/nlon,nlat/),"float")

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
  res@cnLevels = (/212/)
  res@cnFillColors = (/"Purple", "Blue"/)
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


