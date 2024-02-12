;
;  This example code illustrates how to access and visualize an OBPG SNPP VIIRS
; netCDF-4 L2 file in NCL. 
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
; $ncl V2013335181200.L2_SNPP_OC.nc.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2020-01-02

begin
  file_name = "V2013335181200.L2_SNPP_OC.nc"

; Read file. 
  eos_file=addfile(file_name, "r")
  
; Read the data field.
  data=eos_file->$"/geophysical_data/chlor_a"$

; Read lat/lon.
  lat=eos_file->$"/navigation_data/latitude"$
  lon=eos_file->$"/navigation_data/longitude"$

; Associate lat/lon with data.
  data@lat2d=lat
  data@lon2d=lon

  xwks=gsn_open_wks("png", file_name+".ncl") ; open workstation

  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@gsnMaximize=True; make plot large
  res@cnLinesOn=False ; turn off contour lines
  res@cnLineLabelsOn=False; turn off contour line labels
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbOrientation="vertical" ; vertical labels
  res@cnMissingValFillPattern=0 ; missing value pattern is set to "SolidFill"
  res@lbLabelAutoStride=True ; ensure no label overlap
  res@tiMainString=file_name

; The most values fall under 0.0 ~ 1.0 range. 
  res@cnLevelSelectionMode="ExplicitLevels";
  res@cnLevels=(/0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 1.0, 2.0, 4.0, 8.0, 16.0, 32.0/)

; Set limits of map, based on the min/max of the dataset latitude/longitude to
; get a zoomed image.
  res@mpLimitMode  = "LatLon"
  res@mpMinLatF = min(data@lat2d) 
  res@mpMaxLatF = max(data@lat2d)  
  res@mpMinLonF = min(data@lon2d) 
  res@mpMaxLonF = max(data@lon2d) 

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  plot=gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first
end