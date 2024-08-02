; 
; This example code illustrates how to access and visualize LAADS VNP09_NRT v1
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

; Usage:save this script and run 
; 
; $ncl VNP09.A2018064.0524.002.2022287210449.hdf.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2024-08-01


begin
; Read data file.
  file_name="VNP09.A2018064.0524.002.2022287210449.hdf"

; To read HDF-EOS2 files, .he2 is appended to the file name.
; For more information, consult section 4.3.2 of [1].
  eos_file=addfile(file_name+".he2", "r")
; Print metadata information.
;  print(eos_file)
  data_raw = eos_file->375m_Surface_Reflectance_Band_I1_SurfReflect_VNP

; Rad the geo-location file [2].
  geo_file_name = "VNP03IMG_NRT.A2018064.0524.001.nc"  
  geo_nc4_file=addfile(geo_file_name, "r")
  
; Print metadata information.
;  print(geo_nc4_file)
  lat = geo_nc4_file->latitude
  lon = geo_nc4_file->longitude


; Apply scale factor and offset according to the MODIS specification.
  data = (data_raw - data_raw@add_offset) * data_raw@scale_factor

; Set unit [3] and long_name for plot.
  data@units = "Reflectance"
  data@long_name = data_raw@hdfeos_name

; Associate lat/lon.
  data@lat2d = lat
  data@lon2d = lon

  xwks = gsn_open_wks("png", file_name + ".ncl") ; open workstation

  res = True
  
  res@cnFillOn = True
  res@cnFillMode = "RasterFill"
  res@cnLineLabelsOn = False
  res@cnLinesOn = False
  res@cnMissingValFillPattern = 0
  res@cnMissingValFillColor = 0
  
  res@gsnMaximize = True
  res@gsnSpreadColors = True
  res@gsnLeftStringFontHeightF = 11
  res@gsnRightStringFontHeightF = 11

  res@lbOrientation = "vertical" ; vertical labels
  res@lbLabelAutoStride = True ; ensure no label overlap

  res@tiMainString = file_name
  
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

; Set map projectoin.
  res@mpProjection = "Orthographic"
  
; Set limits of map for zoom-in view.
  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d)
  res@mpMaxLatF	= max(data@lat2d)
  res@mpMinLonF	= min(data@lon2d)
  res@mpMaxLonF	= max(data@lon2d)

; Put grid lines.
  res@mpGridAndLimbOn = True

; Change map center.
  dimsize = dimsizes(data)
  nlon = dimsize(0) 
  nlat = dimsize(1)
  res@mpCenterLonF = lon(nlon/2, nlat/2)
  res@mpCenterLatF = lat(nlon/2, nlat/2)
  res@mpFillOn = False

; Show latitude values.
  res@pmTickMarkDisplayMode = "Always"
  res@trGridType = "TriangularMesh"
  
  plot = gsn_csm_contour_map(xwks,data,res)
end

; References
;
; [1] http://hdfeos.org/software/ncl.php.
; [2] https://cmr.earthdata.nasa.gov/search/concepts/C2105092163-LAADS.html
; [3] https://viirsland.gsfc.nasa.gov/PDF/VIIRS_Surf_Refl_UserGuide_v1.3.pdf