;
;  This example code illustrates how to access and visualize LP DAAC ECOSTRESS
; L2 HDF5 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage:
;
;   $ncl ECOSTRESS_L2_LSTE_30192_017_20231102T165047_0601_01.h5.z.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2023-11-06

begin
; Read file. 
  file_name = "ECOSTRESS_L2_LSTE_30192_017_20231102T165047_0601_01.h5"
  file_name_geo = "ECOSTRESS_L1B_GEO_30192_017_20231102T165047_0601_01.h5"  
  h5_file = addfile(file_name, "r") 
  h5_file_geo = addfile(file_name_geo, "r") 
; See what variables are available.
;  print(h5_file)
;  print(h5_file_geo)

; Read Latitude.
  lat = h5_file_geo->latitude

; Read Longitude.
  lon = h5_file_geo->longitude

; Read Land Surface Temperature (LST) data.
  data = short2flt(h5_file->LST)
;  printVarSummary(data)
  data@lat2d = lat
  data@lon2d = lon
  xwks=gsn_open_wks("png", file_name+".z.ncl")
  
  res=True

  res@cnFillMode="RasterFill"    
  res@cnFillOn=True
  res@cnLinesOn=False
  res@cnLineLabelsOn=False
  res@cnMissingValFillColor=0
  res@cnMissingValFillPattern=0
  
  res@gsnMaximize=True  
  res@gsnSpreadColors=True

  res@lbOrientation="vertical"


  
  ; The next 5 statements are for a zoomed image.
  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d)
  res@mpMaxLatF	= max(data@lat2d)
  res@mpMinLonF	= min(data@lon2d)
  res@mpMaxLonF	= max(data@lon2d)


  
  res@trGridType = "TriangularMesh"
  gsn_define_colormap(xwks, "BlAqGrYeOrReVi200")

  res@tiMainString=file_name
  plot=gsn_csm_contour_map_ce(xwks, data, res)

  ; Use the following for different projection.
  ; res@mpProjection="LambertEqualArea"
  ; plot=gsn_csm_contour_map(xwks, data, res)
end

