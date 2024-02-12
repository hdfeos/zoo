;  This example code illustrates how to access and visualize GES-DISC HIRDLS
;  Vertical Profile HDF-EOS5 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.0.0
; Last updated: 2012-04-26

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
; Read file. 
; To read HDF-EOS5 files, .he5 is appended to the argument. 
; For more information, consult section 4.3.2 of [1]. 
  file_name = "HIRDLS-Aura_L2_v06-00-00-c01_2008d001.he5"
  eos_file=addfile(file_name, "r") 

; Print what variables are available for plot.
  print(eos_file)

; Read geo-location/time variables.
  pressure=eos_file->Pressure_HIRDLS
  pressure@units = eos_file->Pressure_HIRDLS@Units
  pressure@long_name = eos_file->Pressure_HIRDLS@Title + " (" + \
  eos_file->Pressure_HIRDLS@Units + ") in log~B~10 ~N~scale" 

  time=eos_file->Time_HIRDLS
  time@units = "seconds since 1993-1-1 00:00:0.0"

; Set subset index.
  index = 0

; Create date time string from TAI-93.
; cd_calendar() is supported since NCL 6.0.0.
; Use ut_calendar() for older version.
  utc_date = cd_calendar(time(index), 0)
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
  data2D=eos_file->O3_HIRDLS
  data=data2D(index,:)  
  data@long_name = data2D@Title +  " (" + data2D@Units + ")"  + " at " + \
                   date_str
  data@units = data2D@Units
  data@_FillValue = data2D@_FillValue
  printVarSummary(data)


; Open workstation
  xwks = gsn_open_wks("pdf", file_name + ".ncl")  
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

  res=True

; Make plot large.
  res@gsnMaximize=True  

; Force portrait orientation.
  res@gsnPaperOrientation = "portrait"  
  res@lbOrientation        = "Vertical"

; Set title with file name.
  res@tiMainString = file_name

; Use log scale along pressure axis.
  res@trYLog = True
  res@xyComputeYMin = True;

; See [2] for gsn_csm_xy() usage.
  plot=gsn_csm_xy(xwks,data,pressure,res) 

  delete(plot)
  delete(res)
  delete(data)
  delete(data2D)
  delete(time)
  delete(pressure)
  delete(eos_file)
end

; References
;
; [1] http://hdfeos.org/software/ncl.php
; [2] http://www.ncl.ucar.edu/Document/Graphics/Interfaces/gsn_csm_xy.shtml