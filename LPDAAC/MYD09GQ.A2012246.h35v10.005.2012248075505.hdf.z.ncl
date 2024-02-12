;
;  This example code illustrates how to access and visualize LP DAAC AQUA
; MODIS  MYD09 HDF-EOS2 Grid file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.1.0
; Last updated: 2013-1-11
load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  file_name = "MYD09GQ.A2012246.h35v10.005.2012248075505.hdf"
; Read file as HDF4 file to retrieve all attributes from data set.
  hdf4_file = addfile(file_name, "r") 
; Read file as HDF-EOS2 file to resolve geo-location fields.
  eos2_file = addfile(file_name+".he2", "r") 

; List all available fields and attributes. 
; print(hdf4_file)
 print(eos2_file)

; read data field
  data_raw = hdf4_file->sur_refl_b01_1

; Filter out invalid values and set them as fill value. 
  data_valid = where(data_raw.gt.data_raw@valid_range(0) .and. data_raw.lt.data_raw@valid_range(1), data_raw, data_raw@_FillValue)

; Apply scale factor according to the MODIS user's guide.
; correct_data_value = (raw_data_value - offset)/scale
; Please note that the value of offset attribute is 0.0.
  data = (data_valid - data_raw@add_offset)/data_raw@scale_factor 

  data@long_name = data_raw@long_name
  data@units = data_raw@units


  lat = eos2_file->GridLat_MODIS_Grid_2D
  lon = eos2_file->GridLon_MODIS_Grid_2D

; Please note that this Grid data field covers the area near 180 longitude, 
; which results -180 for min value and 180 for max value 
; although the data field doesn't cover the entire longitude [-180, 180].
;
; Thus, unlike other NCL examples, we need to adjust map limits carefully.
; 
; To achieve the goal of plotting correctly, we used the following line.
; (i.e. we added 360 for longitude that is less than 0. )
; Then, you can plot a zoomed image correctly by setting limits for min / max 
; values later.
  lon = where(lon.gt.0, lon, lon+360)

; Associate longitude and latitude.
  data@lat2d = lat
  data@lon2d = lon

  xwks = gsn_open_wks("pdf", file_name+ ".z.ncl") ; open workstation

; The plot needs more memory since the array size is big.
  setvalues NhlGetWorkspaceObjectId() ; make maximum filesize larger
  "wsMaximumSize" : 200000000
  end setvalues

  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn =  False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@lbOrientation = "vertical" ;vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0; white color for missing values

  res@gsnLeftStringFontHeightF=18 ; make font smaller
  res@gsnRightStringFontHeightF=18 ; make font smaller

 ; Set limits of map, based on the min/max of the dataset latitude/longitude
  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d)
  res@mpMaxLatF	= max(data@lat2d)  
  res@mpMinLonF	= min(data@lon2d) 
  res@mpMaxLonF	= max(data@lon2d) 

; Again, this data field covers the area near 180 longitude.
  res@mpCenterLonF = 180.0;

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
  res@tiMainString = file_name ; create title

  res@trGridType = "triangularmesh"; speed up processing.
  plot = gsn_csm_contour_map_ce(xwks,data,res) ; create plot

; Clean up used resources.
  delete(plot)
  delete(xwks)
  delete(data_raw)
  delete(data_valid)
  delete(data)
  delete(res)
  delete(eos2_file)
  delete(hdf4_file)
end