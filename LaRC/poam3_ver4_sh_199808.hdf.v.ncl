;
;   This example code illustrates how to access and visualize LaRC POAM3
;  HDF4 Swath file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage:  save this script and run
;
;    $ncl poam3_ver4_sh_199808.hdf.v.ncl
;
; The HDF file must be in your current working directory.
;
; Tested under: NCL 6.6.2
; Last updated: 2022-05-19
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"

begin
  file_name = "poam3_ver4_sh_199808.hdf"
  hdf_file = addfile(file_name, "r") 
;  print(hdf_file)

  wv = hdf_file->wavelength
  alt = hdf_file->z_aerosol
  date = hdf_file->date
  sec = hdf_file->sec

; Read dataset.
  w = 0 ; 0 is for 0.355 nm wavelength. Change this for different wavelength.
  data = hdf_file->aerosol(:,w,:) 
  data = data
  
  data@long_name = data@long_name + " at " + wv@long_name + "=" + wv(w) + "(" + wv@units + ")"
  
; Associate data with coordinate variables.
  dt_str = tostring(date)+sprinti("%0.2i", toint(floor(sec/3600)))
  format = "%Y%N%D%H"
  dt = cd_inv_string(dt_str, format)
  data&revindex = tofloat(dt)

  xwks = gsn_open_wks ("png", file_name + ".v.ncl")    ; open workstation
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn = False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@lbOrientation = "vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0; white color for missing values
  res@lbLabelAutoStride = True ; ensure no label overlap
  res@tiMainString = file_name
  res@tiYAxisString = alt@long_name + " ("+alt@units+")"
  res@tiYAxisFontHeightF = 0.018 
  res@tmXBMode = "Explicit"
  res@tmXBValues = (/0,  200, 434/)
  res@tmXBLabels = (/cd_string(dt(0), "%N/%D"), cd_string(dt(200), "%N/%D"), cd_string(dt(434), "%N/%D")/)
  plot = gsn_csm_contour(xwks, data, res)
end
