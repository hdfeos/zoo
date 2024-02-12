; 
;  This example code illustrates how to access and visualize
;  LP DAAC MOD09GA v6 HDF-EOS2 Grid file using NCL. 
;
;  If you have any questions, suggestions, comments  on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage:save this script and run 
; 
; $ncl MOD09GA.A2007268.h10v08.006.2015166222724.hdf.ncl
; 
; Tested under: NCL 6.4.0
; Last updated: 2018-04-17 


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  file_name = "MOD09GA.A2007268.h10v08.006.2015166222724.hdf"

; By adding .he2, NCL will open the file using HDF-EOS2 library instead of HDF4
; library. HDF-EOS2 library can resolve geo-location information automatically.
  he2_file = addfile(file_name+".he2", "r")
  
; List available fields and attributes.   
;  print(he2_file)

; Read data field.
  data_raw = he2_file->Range_1_MODIS_Grid_1km_2D
  data_valid = tounsigned(data_raw)
  valid_min = tounsigned(data_raw@valid_range(0))
  valid_max = tounsigned(data_raw@valid_range(1))  
; Filter out invalid values and set them as fill value. 
  data_valid = where(data_valid.ge.valid_min .and. data_valid.le.valid_max, data_valid, data_raw@_FillValue)

; FillValue is 0, which will trigger a warning message for NCL during plotting.
; Change it to a different value (e.g., 1) that is outside of valid range.
; 'h' in 1h indicates 'short' type.  
  data_valid=where(data_valid.eq.data_raw@_FillValue, 1h, data_valid)
  data_valid@_FillValue = 1h

  
; Apply scale factor.
; NCL, by default, treats ushort as short. Convert type to unsigned.
;   data = tounsigned(data_valid) / data_raw@scale_factor
  data = data_valid / data_raw@scale_factor

; Copy key metadata.
  data@long_name = data_raw@long_name
  data@units = data_raw@units
  data@_FillValue = 1h
  
; Associate longitude and latitude.
  data@lat2d = he2_file->GridLat_MODIS_Grid_1km_2D
  data@lon2d = he2_file->GridLon_MODIS_Grid_1km_2D

; Open workstation.
  xwks = gsn_open_wks("png", file_name+".ncl") 

  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn =  False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@lbOrientation = "vertical" ;vertical labels
  res@gsnLeftStringFontHeightF=18 ; make font smaller
  res@gsnRightStringFontHeightF=18 ; make font smaller
  
; Set limits of map, based on the min/max of the dataset latitude/longitude.
; This will create a zoom-in effect.  
  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d) 
  res@mpMaxLatF	= max(data@lat2d)  
  res@mpMinLonF	= min(data@lon2d) 
  res@mpMaxLonF	= max(data@lon2d) 

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")
  
; Create title.
  res@tiMainString = file_name

; Create plot.
  plot = gsn_csm_contour_map_ce(xwks,data,res) 

; Clean up resources.
  delete(plot)
  delete(xwks)
  delete(data_raw)
  delete(data_valid)
  delete(data)
  delete(res)
  delete(he2_file)
end