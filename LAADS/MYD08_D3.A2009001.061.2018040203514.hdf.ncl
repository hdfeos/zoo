; 
; This example code illustrates how to access and visualize LAADS MOD08_D3 v6.1
; HDF-EOS2 Grid file in NCL.
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
; $ncl MYD08_D3.A2009001.061.2018040203514.hdf.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2024-05-31

begin
; Read data file.
  file_name="MYD08_D3.A2009001.061.2018040203514.hdf"
  
; To read HDF-EOS2 files, .he2 is appended to the file name.
; For more information, consult section 4.3.2 of [1].
;
; BUG: NCL 6.4.0 cannot read it as HDF-EOS2 file properly.
; 
;  eos_file=addfile(file_name+".he2", "r")
;  print(eos_file)

; Rad the file as an HDF4 file instead.
  hdf4_file=addfile(file_name, "r")

; Print metadata information.
;  print(hdf4_file)

  data_hdf4 = hdf4_file->Cloud_Fraction_Mean
  lat = hdf4_file->YDim
  lon = hdf4_file->XDim
  lat@units = "degrees_north"
  lon@units = "degrees_east"
  
; Filter out invalid values and set them as fill value.
  data_valid=where(data_hdf4.lt.data_hdf4@valid_range(0) .or. data_hdf4.gt.data_hdf4@valid_range(1), data_hdf4@_FillValue, data_hdf4)
  data_valid@_FillValue = data_hdf4@_FillValue
   
; Apply scale factor and offset according to the MODIS specification.
  data = (data_valid - data_hdf4@add_offset) * data_hdf4@scale_factor

; Set unit and long_name for plot.
  data@unit = data_hdf4@units
  data@long_name = data_hdf4@long_name

; Associate lat/lon.
  data!0 = "lat"
  data!1 = "lon"
  data&lat = lat
  data&lon = lon

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

; Make lines thicker to see coastlines better.
  res@mpGeophysicalLineThicknessF = "4.0"
  
  res@tiMainString = file_name
  
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

  plot = gsn_csm_contour_map_ce(xwks,data,res)
  
; Clean up resources used.
  delete([/data, data_valid, data_hdf4/])
  delete([/plot, res, xwks, hdf4_file/])
end

; References
;
; [1] http://hdfeos.org/software/ncl.php.