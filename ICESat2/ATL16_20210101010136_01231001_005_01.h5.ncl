;
;  This example code illustrates how to access and visualize ICESat-2 ATL16
; L3B HDF5 file in NCL. 
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
;   $ncl ATL16_20210101010136_01231001_005_01.h5.py
;
; Tested under: NCL 6.6.2
; Last updated: 2024-03-07

begin
; Read file. 
  file_name = "ATL16_20210101010136_01231001_005_01.h5";
  h5_file=addfile(file_name, "r") 

; See what variables are available.
;  print(h5_file)

; Read Latitude.
  lat = h5_file->/global_grid_lat
; Read Longitude.
  lon = h5_file->/global_grid_lon
  lon = lon - 180
; Read Global Apparent Surface Reflectance (ASR).
  data = h5_file->/global_asr
  xwks=gsn_open_wks("png", file_name+".ncl")
  
  res=True
  res@cnFillOn=True
  res@gsnMaximize=True
  res@cnLinesOn=False
  res@cnLineLabelsOn=False
  res@gsnSpreadColors=True
  res@cnFillMode="RasterFill"
  res@lbOrientation="vertical"
  res@cnMissingValFillPattern=0
  res@cnMissingValFillColor=0

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

  res@tiMainString=file_name
  plot=gsn_csm_contour_map_ce(xwks,data,res)
end

