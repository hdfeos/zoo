;  This example code illustrates how to access and visualize LAADS_MYD swath 
; file in NCL. 
;
; If you have any questions, suggestions, comments  on this example,
;  please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
; If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 2-D swath file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
; To read HDF-EOS2 files, .he2 is appended to the filename.
; For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.
  file_name = "MYD07_L2.A2002184.2200.005.2006133121629.hdf"
  eos_file = addfile(file_name+".he2", "r")

; Rad the same file as an HDF4 file to retrieve attributes.
  hdf4_file = addfile(file_name, "r")

  data_unscaled = eos_file->Water_Vapor_mod07 ; read data field
  data_hdf4 = hdf4_file->Water_Vapor

; In order to read the Water_Vapor data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

  data = data_unscaled*0.0010000000474974513; scale factor given from the file
  data@lat2d = eos_file->Latitude_mod07 ; associate longitude and latitude
  data@lon2d = eos_file->Longitude_mod07 ; 
  data@long_name = data_hdf4@long_name
  data@units = data_hdf4@units



  xwks = gsn_open_wks("pdf","MYD07_L2.A2002184.2200.005.2006133121629_Water_Vapor") ; open workstation

  res = True ; plot mods desired
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


  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap


  plot = new(2, "graphic") ; allocate plot
  res@tiMainString = file_name ; create title.
  plot(0) = gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first

  delete(res@tiMainString) ; delete title for subsequent plots
  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
  res@mpMaxLatF	= max(data@lat2d)  
  res@mpMinLonF	= min(data@lon2d) 
  res@mpMaxLonF	= max(data@lon2d) 

  plot(1) = gsn_csm_contour_map_ce(xwks,data,res) 

; Clean up resources.
  delete(plot) 
  delete(xwks)
  delete(data)
  delete(data_hdf4)
  delete(data_unscaled)
  delete(res)
  delete(eos_file)
end






