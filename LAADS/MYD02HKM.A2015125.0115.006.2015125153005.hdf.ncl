; 
; This example code illustrates how to access and visualize LAADS MYD02HKM v6
; HDF-EOS2 Swath file in NCL.
;
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Usage:save this script and run 
; 
; $ncl MYD02HKM.A2015125.0115.006.2015125153005.hdf.ncl
;
; Tested under: NCL 6.4.0
; Last updated: 2018-02-19

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; Read data file.
  file_name="MYD02HKM.A2015125.0115.006.2015125153005.hdf"
  eos_file=addfile(file_name+".he2", "r")
; print(eos_file)

; Rad the same file as an HDF4 file to retrieve attributes.
  hdf4_file = addfile(file_name, "r")

; Uncomment to the following line to print all variables and attributes.
;  print(hdf4_file)

; Read data field.
; In order to read the from the HDF-EOS2 file, 
; the group under which the data field is placed must be appended to the data 
; field in NCL. For more information, visit section 4.3.2 of [1].
  data_unscaled = eos_file->EV_500_RefSB_MODIS_SWATH_Type_L1B(0,:,:) 
  data_hdf4 = hdf4_file->EV_500_RefSB
  data_unscaled@_FillValue =  data_hdf4@_FillValue

; Filter out invalid values and set them as fill value.
  data_valid=where(data_unscaled.gt.data_hdf4@valid_range(0) .and. data_unscaled.lt.data_hdf4@valid_range(1), data_unscaled, data_unscaled@_FillValue)

; Apply scale factor and offset according to [2].
  data = (data_unscaled - data_hdf4@reflectance_offsets(0)) * data_hdf4@reflectance_scales(0)

  dimsize=dimsizes(data)
  nlon=dimsize(0) 
  nlat=dimsize(1) 

; We need to use eosdump to generate lat and lon
; For information on how to obtain the lat/lon data, check [3].
; To properly display the data, the latitude/longitude must be remapped.
  lat=asciiread("lat_MYD02HKM.A2015125.0115.006.2015125153005.output",(/nlon,nlat/),"float")
  lon=asciiread("lon_MYD02HKM.A2015125.0115.006.2015125153005.output",(/nlon,nlat/),"float")

  data@lat2d=lat
  data@lon2d=lon


; The plot is derived using the reflectance offset and scale according to [2]. 
; Thus, add a more descriptive field name.
  data@long_name = "Reflectance derived from~C~" + data_hdf4@long_name + "~C~at " + data_hdf4!0 + "=0"
  data@units = data_hdf4@reflectance_units

; Read geolocation file.

  xwks = gsn_open_wks("png", file_name + ".ncl") ; open workstation

  res = True ; plot mods desired
  
  res@cnFillOn = True ; enable contour fill
  res@cnFillMode = "RasterFill" ; faster
  res@cnLineLabelsOn = False ; turn off contour line labels  
  res@cnLinesOn = False ; turn off contour lines
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0 ; white color for missing values
  
  res@gsnMaximize = True ; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@gsnLeftStringFontHeightF = 11 ; make font smaller
  res@gsnRightStringFontHeightF = 11 ; make font smaller

  res@lbOrientation = "vertical" ; vertical labels
  res@lbLabelAutoStride = True ; ensure no label overlap

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") 


  res@mpProjection = "Orthographic"
  res@mpLimitMode = "LatLon"
; Set limits of map.
  res@mpMinLatF	= min(data@lat2d)
  res@mpMaxLatF	= max(data@lat2d)
  res@mpMinLonF	= min(data@lon2d)
  res@mpMaxLonF	= max(data@lon2d)
  res@mpGridAndLimbOn     = True ; Put Grid lines
; Change map center.
  res@mpCenterLonF        = lon(nlon/2, nlat/2)
  res@mpCenterLatF        = lat(nlon/2, nlat/2)
  res@mpFillOn = False
  
; Show latitude values.
  res@pmTickMarkDisplayMode = "Always"
  
  res@tiMainString = file_name
  res@trGridType = "TriangularMesh"
  plot = gsn_csm_contour_map(xwks,data,res)
  
; Clean up resources used.
  delete([/plot,res,xwks,eos_file/])
  delete([/data, data_valid, data_hdf4, data_unscaled/])
end
