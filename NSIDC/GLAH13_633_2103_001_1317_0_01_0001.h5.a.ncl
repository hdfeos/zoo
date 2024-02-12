;
;  This example code illustrates how to access and visualize ICESAT GLAS
; L2 HDF5 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.1.0
; Last updated: 2013-1-14


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
; Read file. 
  file_name = "GLAH13_633_2103_001_1317_0_01_0001.h5";
  h5_file=addfile(file_name, "r") 

; See what variables are available.
;  print(h5_file)

; Read Latitude.
  lat_raw = h5_file->/Data_1HZ/Geolocation/d_lat

; Read Longitude.
  lon_raw = h5_file->/Data_1HZ/Geolocation/d_lon

; Read Time.
; The following will not work on NCL 6.1.0.
;  time = h5_file->/Data_1HZ/d_UTCTime_1

  time = h5_file->/Data_1HZ/DS_UTCTime_1

; Read Surface temperature.
  temp = h5_file->/Data_1HZ/Atmosphere/d_Surface_temp


; We used HDFView to check lat/lon values and found that there are many fill 
; values in lat/lon.
; Process fill values using the fact that  lat_raw(1) and lon_raw(1) are fill 
; values in this file's case.
; Again, you need to check them using HDFView for different files.
   lat = lat_raw
   lon = lon_raw
   lat@_FillValue = lat_raw(1)
   lon@_FillValue = lon_raw(1)


; Create an elapsed time variable.
  telapse = time - time(0)
  telapse@long_name = "Elapsed Time"
  telapse@units = "seconds"

; Open workstation.
  xwks = gsn_open_wks ("pdf", file_name + ".a.ncl")  
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

; Allocate space for 3 plots.
  plot = new(3, "graphic")
  res = True
  res@gsnMaximize = True   
  res@gsnPaperOrientation = "portrait" 
  res@lbOrientation = "Vertical"
  res@tiMainString = file_name 
  res@tiXAxisString = telapse@long_name + " (" + telapse@units + ")"
; If you want to see line, not marker plots, comment out the following 3
; lines.
  res@xyMarkLineModes = "MarkLines"
  res@xyMarkerColor = "Blue"
  res@xyMarkers = 5
  res@tiYAxisString = temp@long_name + " (" + temp@units + ")"
  plot(0)=gsn_csm_xy(xwks, telapse, temp, res)

; Locate the a starting point of the flight path.
  mpres = True
  mpres@tiMainString = "Starting Location of Flight Path"
  mpres@gsnFrame = False ; Don't advance the frame
  mpres@gsnMaximize= True
  mpres@gsnPaperOrientation= "portrait"; force portrait
  mpres@mpLandFillColor= "Green"; color of land

; Comment out the following 4 lines if you don't want to see the map in
; "Ortho" projection.
  mpres@mpProjection = "Orthographic"
  mpres@mpGridAndLimbOn = True
  mpres@mpCenterLonF = 180.0
  mpres@mpCenterLatF = lat(0)
  plot(1) = gsn_csm_map(xwks,mpres) ; Draw map

; Uncomment this if you want to use Cylindrical Equidistant projection.
;  plot = gsn_csm_map_ce(xwks,mpres) ; Draw map
  gsres = True; "Graphic Style" resources
  gsres@gsMarkerSizeF= 10.0; Marker size
  gsres@gsMarkerThicknessF = 1.0 ; Marker thickness
  gsres@gsMarkerColor= "Blue"; Marker color
  gsres@gsMarkerIndex= 1 ; Marker style
 ; Lon values range from 0-360.
  gsres@mpCenterLonF = 180.0

; Plot trajectory marker.
  gsn_polymarker(xwks,plot(1),lon,lat,gsres)

; Add a starting point in red color.
  gsres@gsMarkerColor= "Red"
  gsres@gsMarkerSizeF= 20.0; Marker size
  gsres@gsMarkerIndex= 2 ; Marker style: '+'
  gsres@gsMarkerThicknessF = 5.0 ; Marker thickness
  gsn_polymarker(xwks,plot(1),lon(0),lat(0),gsres) 
  frame(xwks)

  zpres = True
  zpres@tiMainString = "Trajectory of Flight Path"
  zpres@gsnFrame = False ; Don't advance the frame
  zpres@gsnMaximize = True
  zpres@gsnPaperOrientation = "portrait"; force portrait
  zpres@mpLandFillColor = "Green"; color of land
  zpres@mpLimitMode = "LatLon"
 ; Lon values range from 0-360.
  zpres@mpCenterLonF = 180.0

 ; This will show grids at the second level.
  zpres@pmTickMarkDisplayMode = "Always"

; Set limits of map, based on the min/max of the dataset latitude/longitude
  plot(2) = gsn_csm_map_ce(xwks, zpres) ; Draw map

; Plot the trajectory line.
  gsn_polyline(xwks,plot(2),lon,lat,zpres)
  gsn_polymarker(xwks,plot(2),lon(0),lat(0),gsres) 
  frame(xwks)

end

