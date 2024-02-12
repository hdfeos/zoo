; 
; This example code illustrates how to access and visualize LAADS MODIS
; MYD06 HDF-EOS2 Swath  file in NCL.
;
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
; $ncl MYD06_L2.A2017224.0755.061.2018034164910.hdf.ncl
;
; Tested under: NCL 6.5.0
; Last updated: 2019-01-02

begin

; Read data file.
  file_name="MYD06_L2.A2017224.0755.061.2018034164910.hdf"
  
; To read HDF-EOS2 files, .he2 is appended to the file name.
; For more information, consult section 4.3.2 of [1].
  eos_file=addfile(file_name+".he2", "r")
;  print(eos_file)


; Read data field using the clues from print(eos_file) output.
  data_raw = eos_file->Cloud_Top_Temperature_mod06
; print(data_raw)

; Filter out invalid values and set them as fill value.
  data_valid = where(data_raw.gt.data_raw@valid_range(0) .and. data_raw.lt.data_raw@valid_range(1), data_raw, data_raw@_FillValue);

  data_valid@_FillValue = data_raw@_FillValue

  data = (data_valid - data_raw@add_offset) * data_raw@scale_factor

  data@lat2d = eos_file->Latitude_mod06
  data@lon2d = eos_file->Longitude_mod06
  data@long_name = data_raw@long_name
  data@units = data_raw@units ; set unit attribute.

  xwks = gsn_open_wks("png", file_name + ".ncl") ; open workstation

  res = True ; plot mods desired
  
  res@cnFillOn = True ; enable contour fill
  res@cnFillMode = "RasterFill" ; faster
  res@cnLineLabelsOn = False ; turn off contour line labels  
  res@cnLinesOn = False ; turn off contour lines
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0 ; white color for missing values
  
  res@gsnMaximize = True ; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@gsnLeftStringFontHeightF = 11 ; make font smaller
  res@gsnRightStringFontHeightF = 11 ; make font smaller

  res@lbOrientation = "vertical" ; vertical labels
  res@lbLabelAutoStride = True ; ensure no label overlap

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") 

  res@mpProjection = "Orthographic"
  res@mpLimitMode = "LatLon"
  
; Set limits of map.
  res@mpMinLatF	= min(data@lat2d)
  res@mpMaxLatF	= max(data@lat2d)
  res@mpMinLonF	= min(data@lon2d)
  res@mpMaxLonF	= max(data@lon2d)
  res@mpGridAndLimbOn     = True ; Put Grid lines
  
; Change map center.
  res@mpCenterLonF        = avg(data@lon2d)
  res@mpCenterLatF        = avg(data@lat2d)

; Show latitude values.
  res@pmTickMarkDisplayMode = "Always"
  
  res@tiMainString = file_name
  res@trGridType = "TriangularMesh"

plot = gsn_csm_contour_map(xwks,data,res)
end

; References
;
; [1] http://hdfeos.org/software/ncl.php