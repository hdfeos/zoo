;  This example code illustrates how to access and visualize LAADS MYD file
; in  NCL. 
;
;  If you have any questions, suggestions, comments  on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Tested under: NCL 6.0.0
; Last updated: 2011-09-27 
;
load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 3-D data field at various levels.

begin
; Read file. 
; Since the file is not HDF-EOS2, it is not necessary to append .he2.
  file_name = "MYDARNSS.Barrow.A2002184.2200.005.2007051063709.hdf"
  eos_file=addfile(file_name, "r")

; Print variables and attributes.
  print(eos_file);

; Read level 10 of EV_1KM_Emissive variable.
  level = 9

; It is not necessary to append the group name because the file is not 
; HDF-EOS2. 
  data_var=eos_file->EV_1KM_Emissive; to access dimension name later.
  data_raw=eos_file->EV_1KM_Emissive(level,:,:) 

; Filter out invalid values and set them as fill value.
  data_valid=where(data_raw.gt.data_raw@valid_range(0) .and. data_raw.lt.data_raw@valid_range(1), data_raw, data_raw@_FillValue)
  data_valid@_FillValue = data_raw@_FillValue

; Apply offset and scale.
; Please note that "radiance_offsets" and "radiance_scales" attributes are 
; arrays.
  data = (data_valid - data_raw@radiance_offsets(level)) * data_raw@radiance_scales(level)

; Associate latitude and longitude.
  data@lat2d=eos_file->Latitude
  data@lon2d=eos_file->Longitude

; Set key attributes.
  data@unit = data_raw@radiance_units
  data@_FillValue = data_raw@_FillValue
  data@long_name = "Radiance derived from~C~" + data_raw@long_name \\
  + "~C~at " + data_var!0+"="+level; "~C~" means carriage return.

  xwks=gsn_open_wks("pdf","MYDARNSS.Barrow.A2002184.2200.005.2007051063709_EV_1KM_Emissive.ncl") ; open workstation

  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@gsnMaximize=True; make plot large
  res@gsnPaperOrientation =	"portrait" ; force portrait orientation
  res@cnLinesOn=False ; turn off contour lines
  res@cnLineLabelsOn       =  False; turn off contour line labels
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbOrientation="vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0; white color for missing values
  res@lbLabelAutoStride = True ; ensure no label overlap
  res@gsnLeftStringFontHeightF=13 ; make text smaller
  res@gsnRightStringFontHeightF=13

  res@mpLimitMode="LatLon"
; Set limits of map, based on the min/max of the dataset latitude/longitude.
  res@mpMinLatF	= min(data@lat2d)
  res@mpMaxLatF	= max(data@lat2d) 
  res@mpMinLonF	= min(data@lon2d) 
  res@mpMaxLonF	= max(data@lon2d)


  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

; Create title with file name and variable name.

  res@tiMainString=file_name; create title.

; Create left text with dimension name and its value.
  plot=gsn_csm_contour_map_ce(xwks,data,res)

; Clean up resources.
  delete(plot) 
  delete(res)
  delete(xwks)
  delete(data)
  delete(data_valid)
  delete(data_raw)
  delete(eos_file)
end


