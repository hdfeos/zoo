; 
; This example code illustrates how to access and visualize LAADS MODIS Swath
; HDF-EOS2 file in NCL.
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
; $ncl MODATML2.A2018046.1040.061.2018046193607.hdf.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2024-07-30

begin

  file_name="MODATML2.A2018046.1040.061.2018046193607.hdf"
  
; To read HDF-EOS2 files, .he2 is appended to the file name.
; For more information, consult section 4.3.2 of [1].
  eos_file=addfile(file_name+".he2", "r")
; print(eos_file)

; Read "Cloud_Fraction" data field.
  data_unscaled=eos_file->Cloud_Fraction_atml2

; Print information about the specific dataset to check scale and offset.
;  printVarSummary(data_unscaled)

; Apply offset and scale using the formula in
; http://modis-atmos.gsfc.nasa.gov/MOD07_L2/format.html. 
; Here, we pick the level 5.
  data =  data_unscaled@scale_factor * \
  (data_unscaled -  data_unscaled@add_offset)

; Associate longitude and latitude.
  data@lat2d = eos_file->Latitude_atml2
  data@lon2d = eos_file->Longitude_atml2

; Copy the unit/long_name from the original unit attribute of the dataset.
  data@units=data_unscaled@units
  data@long_name=data_unscaled@long_name
  
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
  
; Uncomment the following to set limits of map.
;  res@mpMinLatF	= min(data@lat2d)
;  res@mpMaxLatF	= max(data@lat2d)
;  res@mpMinLonF	= min(data@lon2d)
;  res@mpMaxLonF	= max(data@lon2d)
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
; [1] http://hdfeos.org/software/ncl.php.