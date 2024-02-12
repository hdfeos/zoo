; 
; This example code illustrates how to access and visualize a LaRC ASDC
; DSCOVR_EPIC L2 HDF5 Swath file in NCL.
;
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Usage:save this script and run 
; 
; $ncl DSCOVR_EPIC_L2_TO3_03_20210301005516_03.h5.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2021-03-19

begin
; Read file.
  file_name="DSCOVR_EPIC_L2_TO3_03_20210301005516_03.h5"
  h5_file=addfile(file_name, "r")

; Print metadata information.
;  print(h5_file)

  data = h5_file->/Ozone
  lat = h5_file->/Latitude
  lon = h5_file->/Longitude

; Handle fill value manually.
  data@_FillValue = -999.0
  
  lat@_FillValue = default_fillvalue(typeof(lat))
  lat = where(abs(lat).gt.1e20, lat@_FillValue, lat)

  lon@_FillValue = default_fillvalue(typeof(lon))
  lon = where(abs(lon).gt.1e20, lon@_FillValue, lon)

  data@lat2d = lat
  data@lon2d = lon

; Set attributes for display.
  data@long_name = "Ozone"
  data@units = "DU"
  
  dimsize = dimsizes(data)
  n = dimsize(0)
  m = dimsize(1)
  
  xwks = gsn_open_wks("png", file_name+".ncl") ; open workstation

  res = True

  res@cnFillOn = True
  res@cnFillMode = "RasterFill"
  res@cnLinesOn = False
  res@cnLineLabelsOn = False  
  res@cnMissingValFillPattern = 0
  
  res@gsnMaximize = True  
  res@gsnSpreadColors = True
  
  res@lbOrientation="vertical"

  res@mpCenterLonF = lon(n/2, m/2)
  res@mpCenterLatF = lat(n/2, m/2)
  res@mpFillOn = False ; Don't make land grey.
; Set limits of map for zoom-in view.
  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d)
  res@mpMaxLatF	= max(data@lat2d)
  res@mpMinLonF	= min(data@lon2d)
  res@mpMaxLonF	= max(data@lon2d)
  res@mpProjection = "Orthographic"
  res@mpGridAndLimbOn = True ; Put Grid lines
  
  ; res@pmTickMarkDisplayMode = "Always"    ; Nicer map tickmarks
  res@tiMainString = file_name
  res@tiMainFontHeightF = 0.02
  res@trGridType = "TriangularMesh"
  
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap
  plot = gsn_csm_contour_map(xwks,data,res) ; plot on world map first        
end

; References
;
;  [1] http://www.ncl.ucar.edu/Applications/Scripts/polyg_17.ncl