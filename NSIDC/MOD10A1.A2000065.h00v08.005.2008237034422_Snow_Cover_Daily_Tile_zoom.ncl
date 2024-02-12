;This example code illustrates how to access and visualize NSIDC_MODIS Grid file in NCL. 
;If you have any questions, suggestions, comments on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; This is an example of a 2-D grid file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin

  eos_file = addfile("MOD10A1.A2000065.h00v08.005.2008237034422.hdf.he2", "r") ; Read file. 
; To read HDF-EOS2 files, .he2 is appended to the argument. 
; For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

  data_byte = eos_file->Snow_Cover_Daily_Tile_MOD_Grid_Snow_500m ; read data field
; read data field, getting the clues about eos_file->Snow_Cover_Daily_Tile_MOD_Grid_Snow_500m
; from print(eos_file)

  data = byte2flt(data_byte)   ;Convert data type from byte to float
  data@_FillValue = 255b

  dimsize = dimsizes(data)
  nlat = dimsize(0)  ; 2400 (from datafield in hdf file)
  nlon = dimsize(1)  ; 2400 (from datafield in hdf file)

; We need tos use eosdump to generate lat and lon
; For information on how to obtain the lat/lon data, check this URL http://hdfeos.org/zoo/note_non_geographic.php

; To properly display the data, the latitude/longitude must be remapped.
  lat = asciiread("lat_MOD10A1.A2000065.h00v08.005.2008237034422.output",(/nlat,nlon/),"float")
  lon = asciiread("lon_MOD10A1.A2000065.h00v08.005.2008237034422.output",(/nlat,nlon/),"float")

; Set the limits for zoomed image.
; 
; Please note that this data field covers near 180 longitude, which results
; -180 for min value and 180 for max value although the data field
; doesn't cover the entire longitude [-180, 180].
;
; Thus, unlike other IDL examples, We need to adjust map limits carefully.
; 
; To achieve the goal of plotting correctly, I used the following line.
; i.e. we can add 360 for longitude that is less than 0. Then, look for min / max values.
  lon = where(lon.gt.0, lon, lon+360)

  data@lat2d = lat
  data@lon2d = lon

  xwks = gsn_open_wks("pdf","MOD10A1.A2000065.h00v08.005.2008237034422_Snow_Cover_Daily_Tile_zoom.ncl") ; open workstation
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

  res@cnLevelSelectionMode = "ExplicitLevels" ; set explict contour levels
  res@cnLevels = (/1,11,25,37,39,50,100,200,254,255/)

  res@lbLabelPosition = "Center" ; label position
  res@lbLabelAlignment = "BoxCenters" ; label orientation
  res@lbLabelStrings = (/"0","1","11","25","37","39","50","100","200","254","255"/)
  res@lbTitleString = (/"0=missing data, 1=no decision, 11=night, 25=no snow, 37=lake, 39=ocean, 50=cloud, 100=lake ice, 200=snow, 254=detector saturated, 255=fill"/)
  res@lbTitlePosition  = "Bottom"
  res@lbTitleFontHeightF = 0.0125

  res@tiMainString = "MOD10A1.A2000065.h00v08.005.2008237034422.hdf" ; create title
  res@gsnLeftString = "Field name: Snow_Cover_Daily_Tile"
  res@gsnRightString = "Units: none"

  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
  res@mpMaxLatF	= max(data@lat2d)
  res@mpMinLonF	= min(data@lon2d)
  res@mpMaxLonF	= max(data@lon2d)

; res@mpMinLatF	= 0.00208333 ; Set limits of map, based on the min/max of the dataset latitude/longitude
; res@mpMaxLatF	= 9.99792
; res@mpMinLonF	= 177.226
; res@mpMaxLonF	= 189.998

  res@mpCenterLonF = 180.0

  plot = gsn_csm_contour_map_ce(xwks,data,res) ; create plot

; print("res@mpMinLatF = " + res@mpMinLatF)
; print("res@mpMaxLatF = " + res@mpMaxLatF)
; print("res@mpMinLonF = " + res@mpMinLonF)
; print("res@mpMaxLonF = " + res@mpMaxLonF)

; print("lon(0,0) = " + lon(0,0))
; print("lon(0," + (nlon/2) + ") = " + lon(0,nlon/2))
; print("lon(0," + (nlon-1) + ") = " + lon(0,nlon-1))

; print("lon(" + (nlat/2) + ",0) = " + lon(nlat/2,0))
; print("lon(" + (nlat/2) + "," + (nlon/2) + ") = " + lon(nlat/2,nlon/2))
; print("lon(" + (nlat/2) + "," + (nlon-1) + ") = " + lon(nlat/2,nlon-1))

; print("lon(" + (nlat-1) + ",0) = " + lon(nlat-1,0))
; print("lon(" + (nlat-1) + "," + (nlon/2) + ") = "+ lon(nlat-1,nlon/2))
; print("lon(" + (nlat-1) + "," + (nlon-1) + ") = "+ lon(nlat-1,nlon-1))

  delete(plot) ; cleaning up used resources
  delete(xwks)
  delete(data)
  delete(data_byte)
  delete(res)
  delete(eos_file)

end