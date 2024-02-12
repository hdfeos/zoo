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

; Tested under: NCL 6.0.1 alpha
; Last updated: 2011-11-10

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  file_name="HIRDLS-Aura_L3ZAD_v06-00-00-c02_2005d022-2008d077.he5"
  eos_file=addfile(file_name, "r") ; Read file. 

; To read HDF-EOS5 files, .he5 is appended to the argument. 
; For more information, consult section 4.3.2 of [1].

; Print what variables are available for plot.
  print(eos_file)

; Read geo-location/time variables.
  pressure=eos_file->Pressure_HIRDLS
  pressure@units = eos_file->Pressure_HIRDLS@Units
  pressure@long_name = eos_file->Pressure_HIRDLS@Title

  lat=eos_file->Latitude_HIRDLS

; The file has "degress_north".
  lat@units = "degrees_north"
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
  data2D=eos_file->NO2Day_HIRDLS

; Read the subset of dataset at a specific date.
  tdim = 0
  data=data2D(tdim,:,:)  
  data@long_name = data2D@Title   + "~C~ at " + date_str
  data@units = data2D@Units
  data@_FillValue = data2D@_FillValue
  printVarSummary(data)


; Associate data with coordinate variables.
  data&nLevels_HIRDLS = pressure;
  data&nLats_HIRDLS = lat;


  xwks   = gsn_open_wks ("pdf", file_name + ".ncl") 
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
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  res@tiMainString = file_name

  plot=gsn_csm_contour(xwks, data(nLevels_HIRDLS|:,nLats_HIRDLS|:), res) 

  delete(plot)
  delete(res)  
  delete(data)
  delete(data2D)
  delete(eos_file)
end

; References
;
; [1] http://hdfeos.org/software/ncl.php

