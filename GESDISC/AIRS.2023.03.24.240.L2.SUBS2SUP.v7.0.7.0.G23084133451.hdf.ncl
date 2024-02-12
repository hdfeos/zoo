;
;   This example code illustrates how to access and visualize GES DISC AIRS v7
; Swath HDF-EOS2 file in NCL. 
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
; $ncl AIRS.2023.03.24.240.L2.SUBS2SUP.v7.0.7.0.G23084133451.hdf.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2023-04-24

begin

  file_name = "AIRS.2023.03.24.240.L2.SUBS2SUP.v7.0.7.0.G23084133451.hdf"

; To read HDF-EOS2 files, .he2 is appended to the argument.
; For more information, consult section 4.3.2 of [2].
  eos_file=addfile(file_name+".he2", "r") ; Read file.

;  print(eos_file)

; Read specific subset of data field.
  data=eos_file->olr_L2_Support_atmospheric_surface_product(:,:)
  
; Associate longitude and latitude.
  data@lat2d=eos_file->Latitude_L2_Support_atmospheric_surface_product
  data@lon2d=eos_file->Longitude_L2_Support_atmospheric_surface_product

; See AIRS L2 user guide [1] for unit specification.
  data@unit = "W/m^2"


  xwks=gsn_open_wks("png", file_name+".ncl")
  res=True 
  res@cnFillOn=True
  res@gsnMaximize=True
  res@gsnPaperOrientation="portrait"
  res@cnLinesOn=False
  res@cnLineLabelsOn=False
  res@gsnSpreadColors=True
  res@cnFillMode="RasterFill"
  res@lbOrientation="vertical"
  res@cnMissingValFillPattern=0
  res@cnMissingValFillColor=0

  ; Uncomment these for Polar view.
  ; res@mpLimitMode="LatLon"
  ; res@mpMinLatF=min(data@lat2d)
  ; res@mpMaxLatF=max(data@lat2d)
  ; res@gsnPolar   = "NH"

  gsn_define_colormap(xwks,"amwg")

  res@tiMainString=file_name
  data@long_name=data@hdfeos_name
  
  ; Polar will give a better view.
  ; plot=gsn_csm_contour_map_polar(xwks,data,res)
  
  plot=gsn_csm_contour_map_ce(xwks,data,res)
end

; Reference
;
; [1] https://airs.jpl.nasa.gov/data/products/v7-L2-L3/
