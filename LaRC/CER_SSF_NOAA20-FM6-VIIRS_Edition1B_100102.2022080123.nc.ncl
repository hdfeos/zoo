;
;  This example code illustrates how to access and visualize LaRC CERES SSF
; NOAA20 FM6 VIIRS L2 netCDF-4/HDF5 file in NCL.
;
;  If you have any questions, suggestions, comments on this example, please use
; the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage:save this script and run 
;
; $ncl CER_SSF_NOAA20-FM6-VIIRS_Edition1B_100102.2022080123.nc.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2022-10-25
;
begin
  file_name = "CER_SSF_NOAA20-FM6-VIIRS_Edition1B_100102.2022080123.nc"
 
; Read as an HDF5 file by adding .h5 since NCL hangs
; when it's read as a netCDF file.
  eos_file = addfile(file_name+".h5", "r")
;  print(eos_file)
; Read dataset and associate longitude and latitude
  data = eos_file->toa_incoming_solar_radiation
  lat = eos_file->instrument_fov_latitude
  lon = eos_file->instrument_fov_longitude
  data@lat2d = lat
  data@lon2d = lon

  i = maxind(data)
  lat_c = lat(i)
  lon_c = lon(i)

  xwks = gsn_open_wks("png", file_name+".ncl") 

  res = True
  
  res@cnFillMode = "RasterFill"   
  res@cnFillOn = True
  res@cnLineLabelsOn = False  
  res@cnLinesOn = False
  res@cnMissingValFillColor = 0  
  res@cnMissingValFillPattern = 0 


  res@gsnMaximize = True
  res@gsnLeftStringFontHeightF = 10 
  res@gsnRightStringFontHeightF = 10
  res@gsnSpreadColors = True

  res@lbLabelAutoStride = True 
  res@lbOrientation = "vertical"
  
  res@mpProjection = "Orthographic"
  res@mpCenterLonF = lon_c
  res@mpCenterLatF = lat_c
  res@mpGridAndLimbOn = True ; Put Grid lines
    
  res@tiMainString = file_name
  res@trGridType = "TriangularMesh"
  
  gsn_define_colormap(xwks, "BlAqGrYeOrReVi200")
  
  map = gsn_csm_contour_map(xwks, data, res)
  
end