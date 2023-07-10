;  This example code illustrates how to access and visualize ASF S1-GUNW
; L3 netCDF-4/HDF5 file in NCL.
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
; $ncl S1-GUNW-A-R-072-tops-20230520_20220618-145958-00044E_00030N-PP-ab21-v2_0_6.nc.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2023-07-07

begin
  file_name = "S1-GUNW-A-R-072-tops-20230520_20220618-145958-00044E_00030N-PP-ab21-v2_0_6.nc"

; Read as an HDF5 file by adding .h5 since NCL throws an error
; when it's read as a netCDF file.
  eos_file = addfile(file_name+".h5", "r")

; List file content.
;  print(eos_file)

; Read dataset and associate longitude and latitude
  data = eos_file->amplitude
  lat = eos_file->latitude
  lon = eos_file->longitude
  xwks = gsn_open_wks("png", file_name+".ncl") ; open workstation

  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True ; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn=False ; turn off contour lines
  res@cnLineLabelsOn = False ; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@lbOrientation = "vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0; white color for missing values
  res@lbLabelAutoStride = True ; ensure no label overlap
  res@gsnAddCyclic = False
  res@gsnLeftStringFontHeightF=10 ; make text smaller
  res@gsnRightStringFontHeightF=10

; Set limits of map, based on the min/max of the dataset latitude/longitude
  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(lat)
  res@mpMaxLatF	= max(lat)
  res@mpMinLonF	= min(lon)
  res@mpMaxLonF	= max(lon)

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap
; Create title.
  res@tiMainString=file_name
  plot=gsn_csm_contour_map_ce(xwks,data(::50, ::50),res) ;
end
