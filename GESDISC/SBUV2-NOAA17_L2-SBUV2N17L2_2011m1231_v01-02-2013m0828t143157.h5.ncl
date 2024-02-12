; 
;  This example code illustrates how to access and visualize GES DISC MEaSUREs
; Ozone swath HDF5 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.6.2
; Last updated: 2019-11-04
begin
; Read file. 
  file_name = "SBUV2-NOAA17_L2-SBUV2N17L2_2011m1231_v01-02-2013m0828t143157.h5"
  h5_file=addfile(file_name, "r") 

; See what variables are available.
;  print(h5_file)  
  data = h5_file->ProfileO3Retrieved
;  printVarSummary(data)  

; Latitude
  lat = h5_file->Latitude
  lat@long_name = "Latitude"
  lat@units = "degrees_north"

; Longitude.
  lon = h5_file->Longitude

; Pressure
  lev = h5_file->PressureLevels
  lev@long_name = "Pressures"
  lev@units = "hPa"

; Time.
  time = h5_file->nTimes
  time@long_name = "nTimes"
  time@units = "seconds since 1993-1-1 00:00:0.0"

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


; Associate data with coordinate variables.
  data&nLevels21 = lev;
  data&nTimes = lat;

  xwks = gsn_open_wks ("png", file_name + ".ncl")    ; open workstation
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")


  res = True ; plot mods desired
  
; Put high pressure at the bottom of Y-axis.
  res@trYReverse=True
  res@tmYLMode   = "Explicit"
  res@tmYLValues = (/1000,100,10,1,0.1,0.0/)
  res@tmYLLabels = "" + res@tmYLValues
  res@tiYAxisString = lev@long_name + " ("+lev@units+")"
  
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

; Select a region that latitude values are monotoic. 
; Otherwise, NCL can't plot latitude label with a warning message:
;
;  "ScalarFieldSetValues: irregular coordinate array \
;     sfXArray non-monotonic: defaulting sfXArray"
;
; You can use HDFView to see the latitude values.
  datas = data(0:70,:)
  utc_date = cd_calendar(time(70), 0)
  year   = tointeger(utc_date(:,0))    
  month  = tointeger(utc_date(:,1))    
  day    = tointeger(utc_date(:,2))
  hour   = tointeger(utc_date(:,3))
  minute = tointeger(utc_date(:,4))
  second = utc_date(:,5)
  date_str2 = sprinti("%0.4i", year)  + "-" + sprinti("%0.2i", month) + "-" + \
              sprinti("%0.2i ", day) +  sprinti("%0.2i", hour) + ":" + \ 
              sprinti("%0.2i", minute) + ":" + sprintf("%0.2f", second) 
  datas@long_name="21-Layer Retrieved Ozone Profile from~C~" + date_str + " to~C~" + date_str2


; Put Pressure on Y-axis and Latitude on X-axis by naming dimension.
  plot=gsn_csm_contour(xwks, datas({nLevels21|:},nTimes|:), res) 
end


