;  This example code illustrates how to access and visualize LaRC TES L2
;  Swath HDF-EOS5 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.0.0 
; Last updated: 2011-12-13

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
  file_name="TES-Aura_L2-O3-Nadir_r0000011015_F05_07.he5";
  eos_file=addfile(file_name, "r") ; Read file. 

; To read HDF-EOS5 files, .he5 is appended to the argument. 
; For more information, consult section 4.3.2 of [1].

; Retrieve the value of data and pressure in specific Time levels
  data_0=eos_file->O3_O3NadirSwath(55,:)
  pressure_0=eos_file->Pressure_O3NadirSwath(55,:)

  data_1=eos_file->O3_O3NadirSwath(155,:)
  pressure_1=eos_file->Pressure_O3NadirSwath(155,:)

  data_2=eos_file->O3_O3NadirSwath(955,:)
  pressure_2=eos_file->Pressure_O3NadirSwath(955,:)

  data_3=eos_file->O3_O3NadirSwath(1555,:)
  pressure_3=eos_file->Pressure_O3NadirSwath(1555,:)

  time=eos_file->Time_O3NadirSwath
  time@units = "seconds since 1993-1-1 00:00:0.0"

; Create date time string.
; NCL supports cd_calendar() from version 6.0.0.
; Use ut_calendar() for older version.
  utc_date = cd_calendar(time(55), 0)
  year   = tointeger(utc_date(:,0))    
  month  = tointeger(utc_date(:,1))    
  day    = tointeger(utc_date(:,2))
  hour   = tointeger(utc_date(:,3))
  minute = tointeger(utc_date(:,4))
  second = utc_date(:,5)
  date_str1 = \
  sprinti("%0.4i", year)  + "-" + sprinti("%0.2i", month) + "-" + \
  sprinti("%0.2i ", day) +  sprinti("%0.2i", hour) + ":" + \ 
  sprinti("%0.2i", minute) + ":" + sprintf("%0.2f", second) 


  utc_date = cd_calendar(time(155), 0)
  year   = tointeger(utc_date(:,0))    
  month  = tointeger(utc_date(:,1))    
  day    = tointeger(utc_date(:,2))
  hour   = tointeger(utc_date(:,3))
  minute = tointeger(utc_date(:,4))
  second = utc_date(:,5)
  date_str2 =  \
  sprinti("%0.4i", year)  + "-" + sprinti("%0.2i", month) + "-" + \
  sprinti("%0.2i ", day) +  sprinti("%0.2i", hour) + ":" + \ 
  sprinti("%0.2i", minute) + ":" + sprintf("%0.2f", second) 

  utc_date = cd_calendar(time(955), 0)
  year   = tointeger(utc_date(:,0))    
  month  = tointeger(utc_date(:,1))    
  day    = tointeger(utc_date(:,2))
  hour   = tointeger(utc_date(:,3))
  minute = tointeger(utc_date(:,4))
  second = utc_date(:,5)
  date_str3 = \
  sprinti("%0.4i", year)  + "-" + sprinti("%0.2i", month) + "-" + \
  sprinti("%0.2i ", day) +  sprinti("%0.2i", hour) + ":" + \ 
  sprinti("%0.2i", minute) + ":" + sprintf("%0.2f", second) 

  utc_date = cd_calendar(time(1555), 0)
  year   = tointeger(utc_date(:,0))    
  month  = tointeger(utc_date(:,1))    
  day    = tointeger(utc_date(:,2))
  hour   = tointeger(utc_date(:,3))
  minute = tointeger(utc_date(:,4))
  second = utc_date(:,5)
  date_str4 = \
  sprinti("%0.4i", year)  + "-" + sprinti("%0.2i", month) + "-" + \
  sprinti("%0.2i ", day) +  sprinti("%0.2i", hour) + ":" + \ 
  sprinti("%0.2i", minute) + ":" + sprintf("%0.2f", second) 



; Open workstation
  xwks = gsn_open_wks("pdf","TES-Aura_L2-O3-Nadir_r0000011015_F05_07_O3_line_lvls.ncl")
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

  res=True
  res@gsnMaximize=True   ;make plot large
  res@gsnPaperOrientation = "portrait"    ;force portrait orientation
  res@lbOrientation        = "Vertical"

; Use log scale for the better quality plot. Otherwise, it's hard to
; see the change of data values along the pressure axis.
  res@trYLog = True

; The following is necessary to avoid "WARNING" message because we 
; use log scale in Y-axis. 
  res@xyComputeYMin = True

; Avoid overlaps in tick mark labels in X-axis since the O3 values
; are very small. (e.g., 0.0000040).
  res@tmLabelAutoStride = True

  res@tiXAxisString = data_0@long_name + " (" + data_0@units + ")"
  res@tiYAxisString = pressure_0@long_name + \
                      "  (" + pressure_0@units + ")"

;  res@lbLabelAutoStride = True ; ensure no label overlap

  res@tiMainString = file_name
  res@gsnLeftString="O3 at " + date_str1  ; create left text
  plot=gsn_csm_xy(xwks, data_0, pressure_0, res) ; 

  delete(res@tiMainString)

  res@gsnLeftString="O3 at " + date_str2   ; create left text
  plot=gsn_csm_xy(xwks, data_1, pressure_1, res) ; 

  res@gsnLeftString="O3 at " + date_str3 ; create left text
  plot=gsn_csm_xy(xwks, data_2, pressure_2, res) ; 

  res@gsnLeftString="O3 at " + date_str4  ; create left text
  plot=gsn_csm_xy(xwks, data_3, pressure_3, res) ; 

  delete(plot)
  delete(res)
  delete(data_0)
  delete(data_1)
  delete(data_2)
  delete(data_3)
  delete(pressure_0)
  delete(pressure_1)
  delete(pressure_2)
  delete(pressure_3)
  delete(eos_file)
end

; References
;
; [1] http://hdfeos.org/software/ncl.php
