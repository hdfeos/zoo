;
;  This example code illustrates how to access and visualize OBPG CZCS netCDF-4
; L3 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please use
; the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage: save this script and run
;
; $ncl C19860011986008.L3m_8D_CHL_chlor_a_9km.nc.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2019-12-06

begin
  file_name = "C19860011986008.L3m_8D_CHL_chlor_a_9km.nc"

; Read file. 
  eos_file=addfile(file_name, "r")
  
; Read the data field.
  data=eos_file->chlor_a
  lon=eos_file->lon
  lat=eos_file->lat
  
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
  datal = log10(data)
  datal@units = data@units
  datal@long_name = data@long_name + " (log_10 scale)"
  datal!0 = "lat"
  datal!1 = "lon"
  datal&lat = lat
  datal&lon = lon
  plot=gsn_csm_contour_map_ce(xwks,datal,res) ; plot on world map first
end