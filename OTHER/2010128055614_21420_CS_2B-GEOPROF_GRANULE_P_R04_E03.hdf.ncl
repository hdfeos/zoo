;  This example code illustrates how to access and visualize CDPC CloudSat 
; Swath file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please use
; the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.0.0
; Last updated: 2011-11-16

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin 
  file_name = "2010128055614_21420_CS_2B-GEOPROF_GRANULE_P_R04_E03.hdf"

  eos_file=addfile(file_name+ ".he2","r") 
  print(eos_file) 

  data_raw = eos_file->Radar_Reflectivity_2B_GEOPROF

  lat =  eos_file->Latitude_2B_GEOPROF

  lon =  eos_file->Longitude_2B_GEOPROF

  lev = eos_file->Height_2B_GEOPROF

; The following name is too long for axis.
; lev@long_name = eos_file@Height_long_name_2B_GEOPROF
; The name also has the reserved '~' character. Escape the '~' character.
; lev@long_name=str_sub_str(lev@long_name, "~", "~~")
  lev@long_name = "Height"
  lev@units = eos_file@Height_units_2B_GEOPROF

  time = eos_file->Profile_time_2B_GEOPROF
  
  time@long_name = eos_file@Profile_time_long_name_2B_GEOPROF
  time@units = eos_file@Profile_time_units_2B_GEOPROF

  hdf4_file=addfile(file_name,"r") 
  print(hdf4_file) 
  data_hdf4 = hdf4_file->Radar_Reflectivity

; Process valid_range. Fill value and missing value will be handled by this
; since they are outside of range values.
  data = where(data_raw.gt.data_hdf4@valid_range(0) .and. data_raw.lt.data_hdf4@valid_range(1), data_raw, data_hdf4@_FillValue)

; Apply factor according to the data spec [1].
  data@_FillValue = data_hdf4@_FillValue
  dataf = tofloat(data)
  dataf = dataf / data_hdf4@factor

  dataf!0 = data_raw!0
  dataf!1 = data_raw!1

; Although 2D height values are all slightly different at each profile 
; time, the difference is not significant. Pick the first one only since
; NCL doesn't allow 2D array for axis variable.
  dataf&nbin_2B_GEOPROF = lev(0,:)
  dataf&nray_2B_GEOPROF = time

  xwks = gsn_open_wks("pdf", file_name + ".ncl") ; open workstation

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  res = True                           ; plot mods desired
  res@cnFillOn = True                  ; enable contour fill
  res@gsnMaximize = True               ; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False                ; turn off contour lines
  res@cnLineLabelsOn = False           ; turn off contour line labels
  res@gsnSpreadColors = True           ; use the entire color spectrum
  res@cnFillMode = "RasterFill"        ; faster
  res@lbOrientation = "vertical"       ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0   ; white color for missing values
  res@lbLabelAutoStride = True    ; ensure no label overlap
  res@tiMainString = file_name
  res@tiXAxisString = time@long_name+" ("+time@units+")" 
  res@tiYAxisString = lev@long_name+" ("+lev@units+")" 
  res@gsnLeftString=data_hdf4@long_name 
  res@gsnRightString=data_hdf4@units 

  plot=gsn_csm_contour(xwks, dataf(nbin_2B_GEOPROF|:,nray_2B_GEOPROF|:), res)

; Create a trajectory plot.
  mpres = True; Plot options desired.
  mpres@tiMainString = "Trajectory of Satellite Path ('+':starting point)"
  mpres@gsnFrame = False ; Don't advance the frame
  mpres@gsnMaximize= True
  mpres@mpLandFillColor= "Green"; color of land
  mpres@gsnPaperOrientation= "portrait"; force portrait
  plot = gsn_csm_map_ce(xwks,mpres) ; Draw map

  pres = True                    ;polyline resources
  pres@gsLineThicknessF = 2.0    ;line thickness
  pres@gsLineColor = "blue"      
  gsn_polyline(xwks,plot,lon,lat,pres) ; plot trajectory line

  sres = True;  poly marker resources
  sres@gsMarkerSizeF= 20.0; Marker size
  sres@gsMarkerThicknessF = 5.0 ; Marker thickness
  sres@gsMarkerColor= "red"; Marker color
  sres@gsMarkerIndex= 2 ; Marker style
  gsn_polymarker(xwks,plot,lon(0),lat(0),sres) ; plot trajectory start marker
  
  eres = True; poly marker resources
  eres@gsMarkerSizeF= 20.0; Marker size
  eres@gsMarkerThicknessF = 5.0 ; Marker thickness
  eres@gsMarkerColor= "black"; Marker color
  eres@gsMarkerIndex= 1 ; Marker style
  end_index = dimsizes(lon) - 1
; plot trajectory end marker
  gsn_polymarker(xwks,plot,lon(end_index),lat(end_index),eres) 

  frame(xwks)

; Clean up resources.
  delete(plot)                  
  delete(eres)
  delete(sres)
  delete(pres)
  delete(mpres)
  delete(res)
  delete(xwks)
  delete(data)
  delete(lat)
  delete(lon)
  delete(hdf4_file)
  delete(eos_file)
end 
; References
;
; [1] http://www.cloudsat.cira.colostate.edu/dataSpecs.php