;
;   This example code illustrates how to access and visualize GES DISC MLS v4
; Swath HDF-EOS5 file [1] in NCL. 
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
; $ncl MLS-Aura_L2GP-BrO_v04-23-c03_2016d302.he5.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2019-11-04

begin

  file_name="MLS-Aura_L2GP-BrO_v04-23-c03_2016d302.he5"
  eos_file=addfile(file_name, "r") ; Read file.
  
  data2D=eos_file->L2gpValue_BrO
  data=data2D(399,:)

  pressure=eos_file->Pressure_BrO
  pressure@units = eos_file->Pressure_BrO@Units
  
  time=eos_file->Time_BrO
  time@units = "seconds since 1993-1-1 00:00:0.0"

; cd_calendar() is supported since NCL 6.0.0.
; Use ut_calendar() for older version.
  utc_date = cd_calendar(time(399), 0)
  year   = tointeger(utc_date(:,0))    
  month  = tointeger(utc_date(:,1))    
  day    = tointeger(utc_date(:,2))
  hour   = tointeger(utc_date(:,3))
  minute = tointeger(utc_date(:,4))
  second = utc_date(:,5)
  date_str = sprinti("%0.4i", year)  + "-" + sprinti("%0.2i", month) + "-" + \
             sprinti("%0.2i ", day) +  sprinti("%0.2i", hour) + ":" + \ 
             sprinti("%0.2i", minute) + ":" + sprintf("%0.2f", second) 


  xwks=gsn_open_wks("png", file_name+".ncl")    ; open workstation
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

  res=True
  res@gsnMaximize=True

  res@tiMainString=file_name
  res@gsnLeftString="BrO at Time = "+date_str
  res@tiYAxisString="Pressure (hPa)"
  res@tiXAxisString="BrO (vmr)"
  res@tmXBLabelFontHeightF=0.01
  
; Put high pressure down.  
  res@trYReverse=True
  
; Convert Y axis to logarithmic.  
  res@xyYStyle="Log"
  res@tmYLMode   = "Explicit"
  res@tmYLValues = (/10, 5.0, 2.5/)
  res@tmYLLabels = "" + res@tmYLValues
;  Read MLS Data Quality Document [2] for useful range in BrO data, which is
;  3.2hPa - 10hPa
  plot=gsn_csm_xy(xwks,data(12:16),pressure(12:16),res)
end

; References
;
; [1] https://cmr.earthdata.nasa.gov/search/concepts/C1251101115-GES_DISC/3
; [2] http://mls.jpl.nasa.gov/data/v4-2_data_quality_document.pdf
