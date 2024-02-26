;
;  This example code illustrates how to access and visualize NSIDC ICESat-2
; ATL02 L1B version 6 HDF5 file in NCL. 
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
; $ncl ATL02_20190520193327_08020311_006_01.h5.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2024-02-26

begin
; Read file. 
  file_name = "ATL02_20190520193327_08020311_006_01.h5"
  h5_file=addfile(file_name, "r") 

; See what variables are available. NCL gives "Segmentation fault:11" error.
;  print(h5_file)
  
  g1 = h5_file=>/gpsr/navigation
  g2 = h5_file=>/atlas/pce1/background
  
; Latitude.
  lat = g1->latitude

; Longitude.
  lon = g1->longitude
  
; Count Data.
  data = g2->bg_cnt_50shot_s

  time = g2->delta_time
  time@units = "seconds since 2018-1-1 00:00:0.0"  
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
             
; Use elapsed time.
  telapse = (time - time(0))
  telapse@long_name = "Elapsed Time"
  telapse@units = "Seconds from "+date_str

; Draw plots.  
  wtype          = "png"
  xwks = gsn_open_wks(wtype, file_name + ".ncl")
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")
  
  xyres = True
  xyres@gsnFrame = False   
; vpXF specifies the location of left edge of the View object's bounding box in NDC space. (default 0.2)                   
  xyres@vpXF             = 0.3
; vpYF specifies the location of top edge of the View object's bounding box in NDC space. (default 0.8)  
  xyres@vpYF             = 0.9                  ; for XY plot
; vpWidthF specifies the width of View object's bounding box in NDC units.
; default = 0.6  
  xyres@vpWidthF         = 0.4
; vpHeightF specifies the height of View object's bounding box in NDC units.
; default = 0.6  
  xyres@vpHeightF        = 0.4  
  xyres@lbOrientation = "Vertical"
  xyres@tiMainString = file_name 
  xyres@gsnCenterString = "/atlas/pce1/background/bg_cnt_50shot_s"
  xyres@tiXAxisString = telapse@long_name + " (" + telapse@units + ")"
  xyres@tiYAxisString = data@long_name + " (" + data@units + ")"
; If you want to see line, not marker plots, comment out the following 3
; lines.
  xyres@xyMarkLineModes = "MarkLines"
  xyres@xyMarkerColor = "Blue"
  xyres@xyMarkers = 10
  plot0=gsn_csm_xy(xwks, telapse, data, xyres)

; Create a trajectory plot.
  mpres = True
  mpres@gsnFrame = False
  mpres@vpXF                 = 0.35
  mpres@vpYF                 = 0.35      
  mpres@vpWidthF             = 0.3
  mpres@vpHeightF            = 0.3
  
  mpres@tiMainString = "Trajectory ('+':starting point)"
  mpres@mpLandFillColor= "Green"; color of land
  mpres@mpProjection = "Orthographic"
  mpres@mpGridAndLimbOn = True
  mpres@mpCenterLonF = 150.0
  mpres@mpCenterLatF = -70.0
  plot1 = gsn_csm_map(xwks, mpres) ; Draw map
  gsres = True; "Graphic Style" resources
  gsres@gsMarkerSizeF= 10.0; Marker size
  gsres@gsMarkerThicknessF = 1.0 ; Marker thickness
  gsres@gsMarkerColor= "Blue"; Marker color
  gsres@gsMarkerIndex= 1 ; Marker style

  gsn_polymarker(xwks,plot1,lon,lat,gsres) ; plot trajectory
  gsn_polyline(xwks,plot1,lon,lat,gsres) ; plot trajectory

; Add a starting point in red color.
  gsres@gsMarkerColor= "Red"
  gsres@gsMarkerSizeF= 20.0; Marker size
  gsres@gsMarkerIndex= 2 ; Marker style: '+'
  gsres@gsMarkerThicknessF = 5.0 ; Marker thickness
  gsn_polymarker(xwks,plot1,lon(0),lat(0),gsres)
  frame(xwks)
end

