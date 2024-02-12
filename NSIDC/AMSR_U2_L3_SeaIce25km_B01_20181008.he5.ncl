;
;  This example code illustrates how to access and visualize NSIDC AMSR_U2 L3 
; Sea Ice 25km HDF-EOS5 Grid file in NCL.
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
; $ncl AMSR_U2_L3_SeaIce25km_B01_20181008.he5.ncl
;
; Tested under: NCL 6.5.0
; Last updated: 2018-10-11

begin
  file_name = "AMSR_U2_L3_SeaIce25km_B01_20181008.he5"
  eos_file=addfile(file_name, "r") ; Read file. 
  ; print(eos_file)

  data_raw=eos_file->SI_25km_NH_89V_DAY_NpPolarGrid25km

  ; Apply scale factor according to user guide.
  data = data_raw * 0.1
  
  ; NCL contouring operation doesn't like 0 as fill value.
  data = where(data.eq.0, default_fillvalue("float"), data)
  data@_FillValue = default_fillvalue("float")

  data@long_name = data_raw@long_name
  data@lon2d=eos_file->GridLon_NpPolarGrid25km
  data@lat2d=eos_file->GridLat_NpPolarGrid25km  
  data@units = "K"
  ; printVarSummary(data)
  
  xwks = gsn_open_wks("png", file_name+".ncl") ; open workstation.
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@gsnMaximize=True; make plot large
  res@gsnPaperOrientation="portrait" ; force portrait orientation
  res@cnLinesOn=False ; turn off contour lines
  res@cnLineLabelsOn=False; turn off contour line labels
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbOrientation="vertical" ;vertical labels
  ; res@cnMissingValFillPattern=0 ; missing value pattern is set to "SolidFill"
  ; res@cnMissingValFillColor=0; white color for missing values
  res@gsnPolar = "NH" ; plot northern hemisphere
  res@mpMinLatF = min(data@lat2d) ; ignore the area outside of the lowest latitude
  res@tiMainString = file_name
  
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
  plot=gsn_csm_contour_map(xwks,data,res)
end
