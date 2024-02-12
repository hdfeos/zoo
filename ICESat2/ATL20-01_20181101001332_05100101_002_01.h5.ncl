;
;  This example code illustrates how to access and visualize an
; NSIDC ICESat-2 ATL20 L3B version 3 HDF5 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage:
;
;   $ncl ATL20-01_20181101001332_05100101_002_01.h5.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2021-05-10

begin
; Read file. 
  file_name = "ATL20-01_20181101001332_05100101_002_01.h5";
  h5_file=addfile(file_name, "r") 

; See what variables are available.
;  print(h5_file)

; Read Latitude.
  lat = h5_file->/grid_lat
; Read Longitude.
  lon = h5_file->/grid_lon
  lon = lon - 180
; Read segment geoid.
  data = h5_file->/monthly/mean_fb
  data@lon2d = lon
  data@lat2d = lat
  xwks = gsn_open_wks("png", file_name+".ncl") ; open workstation

  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn =  False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@lbOrientation = "vertical" ;vertical labels
  res@gsnPolar = "NH" ; plot northern hemisphere
  res@mpMinLatF = min(data@lat2d) ; ignore the area outside of the lowest latitude

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
  res@tiMainString = file_name ; create title
  plot = gsn_csm_contour_map(xwks,data,res) ; create plot
end

