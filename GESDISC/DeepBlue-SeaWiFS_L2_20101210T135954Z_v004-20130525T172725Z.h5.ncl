;
;  This example code illustrates how to access and visualize GES DISC MEaSUREs
; SeaWiFS L2 Swath HDF5 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
;
; Usage:save this script and run 
;
; $ncl DeepBlue-SeaWiFS_L2_20101210T135954Z_v004-20130525T172725Z.h5.ncl
;
; Tested under: NCL 6.4.0
; Last updated: 2018-01-18


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
; Read file. 
  file_name = "DeepBlue-SeaWiFS_L2_20101210T135954Z_v004-20130525T172725Z.h5";
  h5_file=addfile(file_name, "r") 

; See what variables are available.
;  print(h5_file)

; Latitude.
  lat = h5_file->latitude

; Longitude.
  lon = h5_file->longitude

; Aerosol data.
  data = h5_file->aerosol_optical_thickness_550_ocean

; Associate 2D lat/lon with data.
  data@lat2d=lat
  data@lon2d=lon

; Create the plot.
  xwks = gsn_open_wks ("png", file_name + ".ncl")    ; open workstation
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap
  res = True;
  
  res@cnFillOn = True ; enable contour fill
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn = False; turn off contour line labels
  res@cnFillMode = "RasterFill" ; faster
  
  res@gsnMaximize = True; make plot large
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@gsnLeftStringFontHeightF = 18.0 ; Make long_name string smaller.
  
  res@lbOrientation = "vertical" ; vertical labels
  res@lbLabelAutoStride = True ; ensure no label overlap

  res@mpProjection = "Orthographic"
  res@mpLimitMode = "LatLon"
  res@mpMinLatF = min((/lat/)) 
  res@mpMaxLatF = max((/lat/))
  res@mpMinLonF = min((/lon/))
  res@mpMaxLonF = max((/lon/))
  res@mpGridAndLimbOn     = True ; Put Grid lines
; Change map center.
  res@mpCenterLonF        = avg(lat)
  res@mpCenterLatF        = avg(lon)

; Show latitude values.  
  res@pmTickMarkDisplayMode        = "Always"
  
  
  res@tiMainString = file_name

  res@trGridType = "TriangularMesh"
  
  plot = gsn_csm_contour_map(xwks,data,res)  

; Clean up resources.
  delete(plot)
  delete(res)
  delete(xwks)
  delete(data)
  delete(lon)
  delete(lat)
  delete(h5_file)
end
