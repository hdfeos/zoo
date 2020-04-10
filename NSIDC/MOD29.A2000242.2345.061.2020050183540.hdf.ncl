; Copyright (C) 2013-2020 by The HDF Group
; All Rights Reserved
;
;  This example code illustrates how to access and visualize NSIDC MOD29 
; HDF-EOS2 Swath file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please use
; the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
;
; Tested under: NCL 6.6.2
; Last updated: 2020-04-10


begin
  file_name = "MOD29.A2000242.2345.061.2020050183540.hdf"

; The following geolocation file name can be found inside the StructMetadata 
; of the MOD29 file. You can use HDFView or
; HDF4 dump tool (hdp) to view the StructMetaata file attribute.
  geo_file_name = "MOD03.A2013196.1250.006.2013196202628.hdf"

; Read the file. To access all attributes, we open it as a pure HDF4 file 
; instead of HDF-EOS2 file.
  eos_file = addfile(file_name, "r") 

; By opening the geo-location file as HDF-EOS2, NCL can change the values
; of units attribute to follow the CF convetions. That is, MOD03 Latitue
; and Longitude datasets have "degress" for units attribute and NCL change
; the value to "degrees_east" and "degrees_north" when the file is opened
; as an HDF-EOS2 file.
;  geo_file = addfile(geo_file_name+".he2", "r")

; Print information about the file to know what variables and attributes are 
; available for plotting.
 print(eos_file)
; print(geo_file)

; Pick a dataset to plot.
 data_raw=eos_file->Ice_Surface_Temperature(::5,::5)

; Print information about the specific dataset.
; printVarSummary(data_raw)

; Filter out invalid values using valid_range attribue.
  data_valid=where(data_raw.gt.data_raw@valid_range(0) .and. data_raw.lt.data_raw@valid_range(1), data_raw, data_raw@_FillValue)

; Convert type.
 data_unscaled = tofloat(data_valid)

; Let's apply scale and offset.
;
; For this dataset, we can't use short2flt() function like below since it 
; computes scale*(data_unscaled - offset).
;
; data = short2flt_hdf(data_unscaled)
;
; For this data product, what we need is data*scale + offset. 
  data = tofloat(data_unscaled * data_raw@scale_factor + data_raw@add_offset)

; Copy the unit attribute and name.
  data@unit = data_raw@units
  data@long_name = data_raw@long_name

; Associate longitude and latitude.
;  longitude = geo_file->Longitude_MODIS_Swath_Type_GEO
;  latitude = geo_file->Latitude_MODIS_Swath_Type_GEO
  longitude = eos_file->Longitude
  latitude = eos_file->Latitude
  data@lon2d=longitude
  data@lat2d=latitude

; Open workstation
  xwks = gsn_open_wks("png", file_name+".ncl") 

  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn =  False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@lbOrientation = "vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@mpLimitMode = "LatLon"
  res@gsnPolar= "SH" ; plot southern hemisphere
  res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
  res@mpMaxLatF	= max(data@lat2d) ; 

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  res@tiMainString=file_name
  plot=gsn_csm_contour_map_polar(xwks,data,res)
end