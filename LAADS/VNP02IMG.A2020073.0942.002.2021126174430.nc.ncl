; 
; This example code illustrates how to access and visualize LAADS VNP02IMG 
; HDF-EOS2 Swath file in NCL.
;
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Usage: save this script and run 
; 
; $ncl VNP02IMG.A2020073.0942.002.2021126174430.nc.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2024-08-10

setvalues NhlGetWorkspaceObjectId() ; make maximum filesize larger
"wsMaximumSize" : 200000000
end setvalues

begin
; Read data file.
  file_name="VNP02IMG.A2020073.0942.002.2021126174430.nc"
  eos_file=addfile(file_name, "r")
; Print metadata information.
;  print(eos_file)
  data_raw = eos_file->I05
  data_raw = where(data_raw.gt.data_raw@valid_min .and. data_raw.lt.data_raw@valid_max, data_raw, data_raw@_FillValue)
;  printVarSummary(data_raw)
  data = short2flt(data_raw)
;  print(min(data))
;  print(max(data))
;  printVarSummary(data)  
  
; Rad the geo-location file [2].
  geo_file_name = "VNP03IMG.A2020073.0942.002.2021125004714.nc"  
  geo_nc4_file=addfile(geo_file_name, "r")
  
; Print metadata information.
;  print(geo_nc4_file)
  lat = geo_nc4_file->latitude
  lon = geo_nc4_file->longitude


; Associate lat/lon.
  data@lat2d = lat
  data@lon2d = lon

  xwks = gsn_open_wks("png", file_name + ".ncl")
  
  res = True

  res@cnFillMode = "RasterFill"
  res@cnFillOn = True
  res@cnLineLabelsOn = False
  res@cnLinesOn = False
  res@cnMissingValFillPattern = 0
  res@cnMissingValFillColor = 0

  res@gsnLeftStringFontHeightF = 11
  res@gsnMaximize = True
  res@gsnSpreadColors = True
  res@gsnRightStringFontHeightF = 11

  res@lbOrientation = "vertical"
  res@lbLabelAutoStride = True

  res@tiMainString = file_name

; Change map center.
  dimsize = dimsizes(data)
  nlon = dimsize(0) 
  nlat = dimsize(1)
  res@mpCenterLonF = lon(nlon/2, nlat/2)
  res@mpCenterLatF = lat(nlon/2, nlat/2)
  res@mpFillOn = False  
; Put grid lines.
  res@mpGridAndLimbOn = True
; Set limits of map for zoom-in view.
  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d)
  res@mpMaxLatF	= max(data@lat2d)
  res@mpMinLonF	= min(data@lon2d)
  res@mpMaxLonF	= max(data@lon2d)
; Set map projectoin.
  res@mpProjection = "Orthographic"

; Show latitude values.
  res@pmTickMarkDisplayMode = "Always"

  res@trGridType = "TriangularMesh"

  gsn_define_colormap(xwks, "BlAqGrYeOrReVi200")
  
  plot = gsn_csm_contour_map(xwks, data, res)
end

; References
;
; [1] http://hdfeos.org/software/ncl.php.
; [2] https://cmr.earthdata.nasa.gov/search/concepts/C2105092163-LAADS.html
