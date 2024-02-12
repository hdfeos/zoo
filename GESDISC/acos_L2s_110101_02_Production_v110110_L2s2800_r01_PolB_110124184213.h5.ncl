;  This example code illustrates how to access and visualize GES DISC GOSAT 
; ACOS L2 Swath HDF5 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.0.0
; Last updated: 2011-11-18


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
; Read file. 
  file_name = "acos_L2s_110101_02_Production_v110110_L2s2800_r01_PolB_110124184213.h5";
  h5_file=addfile(file_name, "r") 

; See what variables are available.
;  print(h5_file)

; We can't use the following string datset since NCL will give a segmentation 
; fault error when it accesses the string dataset.
; print(h5_file->sounding_time_string)

; Time.
  time = h5_file->sounding_time_tai93
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

; Use elapsed time since time granule increases by 7 seconds.
  telapse = (time - time(0))
  telapse@long_name = "Elapsed Time"
  telapse@units = h5_file->sounding_time_tai93@Units

; Use h5_file->sounding_latitude_geoid instead of h5_file->sounding_latitude
; according to [1].
;
; Latitude.
  lat = h5_file->sounding_latitude_geoid
  lat@long_name = "latitude"
  lat@units = h5_file->sounding_latitude_geoid@Units

; Use h5_file->sounding_longitude_geoid instead of h5_file->sounding_longitude
; according to [1].
;
; Longitude.
  lon = h5_file->sounding_longitude_geoid
  lon@long_name = "longitude"
  lon@units = h5_file->sounding_longitude_geoid@Units

; Altitude
  lev = h5_file->sounding_altitude
  lev@long_name = "altitude"
  lev@units = h5_file->sounding_altitude@Units

; CO2 Data.
  data = h5_file->xco2
  data@long_name = "xco2"
  data@units = h5_file->xco2@Units

  xwks = gsn_open_wks ("pdf", file_name + ".ncl")    ; open workstation
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

  res = True
  res@gsnMaximize = True   
  res@gsnPaperOrientation = "portrait" 
  res@lbOrientation = "Vertical"
  res@tiMainString = file_name 
  res@gsnCenterString = "Start Time = " + date_str
  res@tiXAxisString = telapse@long_name + " (" + telapse@units + ")"
  res@tiYAxisString = data@long_name + " (" + data@units + ")"
; If you want to see line, not marker plots, comment out the following 3
; lines.
  res@xyMarkLineModes = "MarkLines"
  res@xyMarkerColor = "Blue"
  res@xyMarkers = 10

  plot=gsn_csm_xy(xwks, telapse, data, res) 

  res@tiYAxisString = lev@long_name + " (" + lev@units + ")"
  plot=gsn_csm_xy(xwks, telapse, lev, res)


; Create a trajectory plot.
  mpres = True
  mpres@tiMainString = "Trajectory ('+':starting point)"
  mpres@gsnFrame = False ; Don't advance the frame
  mpres@gsnMaximize= True
  mpres@gsnPaperOrientation= "portrait"; force portrait
  mpres@mpLandFillColor= "Green"; color of land
; Comment out the following 4 lines if you don't want to see the map in "Ortho" 
; projection, which is more realistic view of the satellite sensor probing path.
  mpres@mpProjection = "Orthographic"
  mpres@mpGridAndLimbOn = True
  mpres@mpCenterLonF = 150.0
  mpres@mpCenterLatF = -70.0
  plot = gsn_csm_map(xwks,mpres) ; Draw map

; Uncomment this if you want to use Cylindrical Equidistant projection.
;  plot = gsn_csm_map_ce(xwks,mpres) ; Draw map

  gsres = True; "Graphic Style" resources
  gsres@gsMarkerSizeF= 10.0; Marker size
  gsres@gsMarkerThicknessF = 1.0 ; Marker thickness
  gsres@gsMarkerColor= "Blue"; Marker color
  gsres@gsMarkerIndex= 1 ; Marker style

  gsn_polymarker(xwks,plot,lon,lat,gsres) ; plot trajectory
  gsn_polyline(xwks,plot,lon,lat,gsres) ; plot trajectory

; Add a starting point in red color.
  gsres@gsMarkerColor= "Red"
  gsres@gsMarkerSizeF= 20.0; Marker size
  gsres@gsMarkerIndex= 2 ; Marker style: '+'
  gsres@gsMarkerThicknessF = 5.0 ; Marker thickness
  gsn_polymarker(xwks,plot,lon(0),lat(0),gsres) 
  frame(xwks)

  delete(plot)
  delete(res)
  delete(lev)
  delete(time)
  delete(telapse)
  delete(lat)
  delete(lon)
  delete(data)
  delete(h5_file)
end
; References
;
; [1] http://disc.sci.gsfc.nasa.gov/acdisc/documentation/acos-data-handling-recipes