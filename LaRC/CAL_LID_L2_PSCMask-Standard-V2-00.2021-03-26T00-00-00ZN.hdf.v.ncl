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
; $ncl CAL_LID_L2_PSCMask-Standard-V2-00.2021-03-26T00-00-00ZN.hdf.v.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2022-09-27

begin
  file_name = "CAL_LID_L2_PSCMask-Standard-V2-00.2021-03-26T00-00-00ZN.hdf"
  
; Read file. 
  hdf_file = addfile(file_name, "r") 

; The following line prints all variables and attributes.
;  print(hdf_file)
  
; The above output provides the following dimension information.
;
; 7871: lat/lon.
; 121: altitude (121 levels between approximately 8.3 and 30.1 km).
; 7871 x 121: PSC_Feature_Mask(fakeDim84 = 7871, fakeDim85 =121).
; The valid range of PSC Feature Mask is [-350, 350].
; See [1] to decode the 3 digit value of PSC properly.

; Potential_Temperature (K) & Pressure (hPa) are 2D.

; Subset region so latitude can be monotonically decreasing.
; You can visualize other blocks by changing subset parameters.
  start = 0
  ssend = 566
  pfm = hdf_file->PSC_Feature_Mask(start:ssend, :)
  
  lat = hdf_file->Latitude(start:ssend)
  lat!0 = "lat"  
  lat@long_name = lat@hdf_name
  lat@units = "degrees_north"
;  printVarSummary(lat)
;  print(lat)
  
  alt = hdf_file->Altitude
  alt!0 = "alt"
  alt@long_name = alt@hdf_name + " (" + alt@units_ + ")"

; Fill value is string and doesn't follow the CF convention.
;  printVarSummary(pfm)
;  print(pfm@fillvalue_)
;  print(typeof(pfm@fillvalue_))
; Set fill value manually.
  pfm@_FillValue = -9999h

; Set long_name attribute.
  pfm@long_name = pfm@hdf_name + " (" + pfm@units_ + ")"
  
  pfm!0   = "lat"
  pfm!1   = "alt"
  pfm&lat = lat
  pfm&alt = alt

  xwks = gsn_open_wks("png", file_name + ".v.ncl") ; open workstation
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True; make plot large
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn =  False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0; white color for missing values
  res@lbLabelAutoStride = True ; ensure no label overlap
  res@tiMainString = file_name
  res@lbOrientation =   "vertical" 

  plot = gsn_csm_contour(xwks, transpose(pfm(::-1,::-1)),res)
end

; See Also
; 
; http://hdfeos.org/zoo/MORE/LaRC/CALIPSO/CAL_LID_L2_VFM-Standard-V4-10.2009-07-13T08-27-14ZD.hdf.v.ncl
;
; Reference
; [1] https://www-calipso.larc.nasa.gov/resources/calipso_users_guide/data_summaries/psc/cal_lid_l2_pscmask_v2-00_desc.php