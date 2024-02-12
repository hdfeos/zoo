;
;  This example code illustrates how to access and visualize a LaRC ASDC g3bssp
;  vertical profile HDF5 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
; 
; Usage:save this script and run 
;
; $ncl g3b.ssp.2022062949SSv05.21.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2022-08-25

begin
; Read file as HDF5 file, not netCDF. 
  file_name = "g3b.ssp.2022062949SSv05.21.h5"
  eos_file=addfile(file_name, "r") 

; Print what variables are available for plot.
;  print(eos_file)

; Read geo-location variables.
  alt=eos_file->Altitude
  lat=eos_file->Latitude
  lon=eos_file->Longitude

; Create date time string.
  utc_date = tostring(eos_file->Date)
  d = str_split_by_length(utc_date, (/4,2,2/))
  date_str = d(0)  + "-" + d(1) + "-" + d(2)
  
  utc_time = tostring_with_format(eos_file->Time, "%0.6i")
  t = str_split_by_length(utc_time, (/2,2,2/))  
  time_str = t(0)  + ":" + t(1) + ":" + t(2)

  dt_str = date_str + "T" + time_str + "Z"
  
; Read the dataset.
  data=eos_file->Ozone_AO3
  data@long_name = data@long_name +  " (" + data@units + ")"  + " at " + \
                   dt_str

; Open workstation.
  xwks = gsn_open_wks("png", file_name + ".ncl")  
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

  res=True

; Make plot large.
  res@gsnMaximize=True  

; Force landscape orientation.
  res@gsnPaperOrientation = "landscape"
  res@lbOrientation        = "Vertical"

; Set title with file name and lat/lon.
  loc_str = "Longitude=" + tostring(lon) + ", Latitude=" + tostring(lat)
  res@tiMainString = file_name + "~C~" + loc_str

  res@tiYAxisString = alt@long_name + " (" + alt@units +")"
  res@xyComputeYMin = True;

; Make x-axis label small.
  res@tmXBLabelFontHeightF = 0.014 

; See [1] for gsn_csm_xy() usage.
  plot=gsn_csm_xy(xwks, data, alt, res) 
end

; References
;
; [1] http://www.ncl.ucar.edu/Document/Graphics/Interfaces/gsn_csm_xy.shtml