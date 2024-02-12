;
;  This example code illustrates how to access and visualize OBPG SeaWiFS
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
; $ncl S1997247162631.L2_MLAC_OC.nc.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2019-12-04

begin
  file_name = "S1997247162631.L2_MLAC_OC.nc"

; Read file. 
  eos_file=addfile(file_name, "r")
  
; Read the data field.
  data_pre=eos_file->$"/geophysical_data/Rrs_412"$
  data_pre@_FillValue=-32767h
  data = short2flt(data_pre)

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

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  plot=gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first
end