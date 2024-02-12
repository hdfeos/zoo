; This example code illustrates how to access and visualize LAADS_MOD swath file in NCL. 
; If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
; If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
; feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; This is an example of plotting a 2-D swath data field of MOD021KM product.

begin

; Read data file. 
  eos_file=addfile("MOD021KM.A2000055.0000.005.2010041143816.hdf", "r")
; print(eos_file)

; Read geolocation file.
; Since dimension maps are used in the eos_file, 
; we must use geolocation values that are stored in a secondary file.
  geo_file = addfile("MOD03.A2000055.0000.005.2010029175839.hdf", "r")
; print(geo_file)

; Read data field using the clues from print(eos_file) output.
  data_raw = eos_file->EV_Band26 
; print(data_raw)

; Filter out invalid values and set them as fill value.
  data_valid = where(data_raw.gt.data_raw@valid_range(0) .and. data_raw.lt.data_raw@valid_range(1), data_raw, data_raw@_FillValue);

  data_valid@_FillValue = data_raw@_FillValue

; We cannot use shoft2flt_hdf() since offset and scale attribute names are not
; standard names.
; data = short2flt_hdf(data_valid);
  data = (data_valid - data_raw@radiance_offsets) * data_raw@radiance_scales

; Asociate longitude and latitude using the clues from the output of 
; print(geo_file) command.
  data@lat2d = geo_file->Latitude 
  data@lon2d = geo_file->Longitude  

  data@long_name = data_raw@long_name
  data@units = data_raw@radiance_units ; set unit attribute.

  xwks = gsn_open_wks("pdf","MOD021KM.A2000055.0000.005.2010041143816_EV_Band26.ncl") ; open workstation

  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True ; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn = False ; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@lbOrientation = "vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0 ; white color for missing values
  res@lbLabelAutoStride = True ; ensure no label overlap

  res@gsnLeftStringFontHeightF = 11 ; make font smaller
  res@gsnRightStringFontHeightF = 11 ; make font smaller

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  res@tiMainString = "MOD021KM.A2000055.0000.005.2010041143816.hdf" ; create title
  res@gsnLeftString = "Radiance derived from " + data@long_name ; create center string using long name
  res@gsnRightString = data@units

  res@mpLimitMode = "LatLon"
; Set limits of map, based on the min/max of the latitude dataset.
  res@mpMinLatF	= min(data@lat2d)
  res@mpMaxLatF	= max(data@lat2d) ;

  res@gsnPolar = "NH" ; specify the hemisphere
  plot=gsn_csm_contour_map_polar(xwks,data,res) ; create the plot

; Clean up resources used.
  delete(plot)
  delete(res)
  delete(xwks)
  delete(data)
  delete(data_valid)
  delete(data_raw)
  delete(geo_file)
  delete(eos_file)

end
