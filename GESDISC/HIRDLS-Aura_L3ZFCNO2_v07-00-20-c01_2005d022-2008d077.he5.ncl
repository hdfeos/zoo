;
;  This example code illustrates how to access and visualize GES-DISC HIRDLS
;  Zonal Average HDF-EOS5 file in NCL. 
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
; $ncl HIRDLS-Aura_L3ZFCNO2_v07-00-20-c01_2005d022-2008d077.he5.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2019-11-04

begin
  file_name="HIRDLS-Aura_L3ZFCNO2_v07-00-20-c01_2005d022-2008d077.he5"
  eos_file=addfile(file_name, "r") ; Read file. 

; To read HDF-EOS5 files, .he5 is appended to the argument. 
; For more information, consult section 4.3.2 of [1].

; Print what variables are available for plot.
;
; Please note that NCL doesn't list dimension variable nCoeffs
; when it reads data as HDF-EOS5 file.
;  print(eos_file)

; Read geo-location/time variables.
  pressure=eos_file->Pressure_HIRDLS
  pressure@units = eos_file->Pressure_HIRDLS@Units
  pressure@long_name = eos_file->Pressure_HIRDLS@Title

  lat=eos_file->Latitude_HIRDLS

; The file has "degress_north".
  lat@units = eos_file->Latitude_HIRDLS@Units
  lat@long_name = eos_file->Latitude_HIRDLS@Title

  time=eos_file->Time_HIRDLS
  time@units = "seconds since 1993-1-1 00:00:0.0"

; Create date time string.
; cd_calendar() is supported since NCL 6.0.0.
; Use ut_calendar() for older version.
  utc_date = cd_calendar(time(0), 0)
  year   = tointeger(utc_date(:,0))    
  month  = tointeger(utc_date(:,1))    
  day    = tointeger(utc_date(:,2))
  hour   = tointeger(utc_date(:,3))
  minute = tointeger(utc_date(:,4))
  second = utc_date(:,5)
  date_str = sprinti("%0.4i", year)  + "-" + sprinti("%0.2i", month) + "-" + \
             sprinti("%0.2i ", day) +  sprinti("%0.2i", hour) + ":" + \ 
             sprinti("%0.2i", minute) + ":" + sprintf("%0.2f", second) 

; Read the dataset.
  data2D=eos_file->NO2Ascending_HIRDLS

; Read the subset of dataset at a specific date.
  tdim = 0
  data=data2D(tdim,:,:,0)
  
; Sicne NCL doesn't provide way to access nCoeffs dimension variable value
; we need to set the nCoeffs[0] value, 1, manually.
; Compare it with Python code that retrieves the value 1 from dataset.  
  data@long_name = data2D@Title   + "~C~ at " + date_str + " and nCoeffs=1"
  data@units = data2D@Units
  data@_FillValue = data2D@_FillValue
;  printVarSummary(data)


; Associate data with coordinate variables.
  data&nLevels_HIRDLS = pressure;
  data&nLats_HIRDLS = lat;


  xwks   = gsn_open_wks ("png", file_name + ".ncl") 
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
  
; Put high pressure at the bottom of Y-axis.
  res@trYReverse=True
  
  res@tmYLMode   = "Explicit"
  res@tmYLValues = (/1000,100,10,1,0.1,0.0/)
  res@tmYLLabels = "" + res@tmYLValues
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap
  res@tiMainString = file_name
  res@tiYAxisString = pressure@long_name + " (" + pressure@units + ")"

  plot=gsn_csm_contour(xwks, data(nLevels_HIRDLS|:,nLats_HIRDLS|:), res) 
end

; References
;
; [1] http://hdfeos.org/software/ncl.php

