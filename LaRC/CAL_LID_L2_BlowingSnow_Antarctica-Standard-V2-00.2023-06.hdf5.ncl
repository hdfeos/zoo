;  This example code illustrates how to access and visualize LaRC CALIPSO
; LIDAR L2 PSCMask HDF4 file in NCL. 
;
;  If you have any questions, suggestions, comments  on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; $ncl CAL_LID_L2_BlowingSnow_Antarctica-Standard-V2-00.2023-06.hdf5.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2024-02-07



begin
  file_name = "CAL_LID_L2_BlowingSnow_Antarctica-Standard-V2-00.2023-06.hdf5"
  
; Read file. 
  hdf_file = addfile(file_name, "r") 

; The following line prints all variables and attributes.
;  print(hdf_file)

;  bs = hdf_file->Blowing_Snow_Backscatter_Profile
;  bs = hdf_file->Blowing_Snow_Color_Ratio_Profile
  bs = hdf_file->Blowing_Snow_Depol_Profile
  data1D = bs(:, 0)
  dimsize = dimsizes(bs)  
  n = dimsize(0)
  m = dimsize(1)
  
  data = reshape(data1D, (/n/2, 2/))
  lon = hdf_file->Longitude
  lon2d = reshape(lon, (/n/2, 2/))
  lon2d@units = "degrees_east"
  
  lat = hdf_file->Latitude
  lat2d = reshape(lat, (/n/2, 2/))
  lat2d@units = "degrees_north"
  
  data@units = bs@units
;  data@long_name = "Blowing_Snow_Backscatter_Profile"
;  data@long_name = "Blowing_Snow_Color_Ratio_Profile"
  data@long_name = "Blowing_Snow_Depol_Profile"  
  data@lat2d = lat2d
  data@lon2d = lon2d
  
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

  res@mpCenterLonF = lon(n/2, 0)
  res@mpCenterLatF = lat(n/2, 0)
  res@mpFillOn = False ; Don't make land grey.

; Set limits of map for zoom-in view.
  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d)
  res@mpMaxLatF	= max(data@lat2d)
  res@mpMinLonF	= min(data@lon2d)
  res@mpMaxLonF	= max(data@lon2d)
  res@mpProjection = "Orthographic"
  res@mpGridAndLimbOn = True ; Put Grid lines

  res@tiMainString = file_name
  res@tiMainFontHeightF = 0.02
  res@trGridType = "TriangularMesh"
  
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap
  plot = gsn_csm_contour_map(xwks,data,res) ; plot on world map first          
end

