; 
; This example code illustrates how to access and visualize LAADS MYD021KM v6.1
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
; $ncl MYD021KM.A2002226.0000.061.2017363061238.hdf.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2024-07-31

begin

; Read data file.
  file_name="MYD021KM.A2002226.0000.061.2017363061238.hdf"
  eos_file=addfile(file_name, "r")
; print(eos_file)

; Read geolocation file.
; Since dimension maps are used in the eos_file, 
; we must use geolocation values that are stored in a secondary file.
  geo_file = addfile("MYD03.A2002226.0000.061.2017362193857.hdf", "r")
; print(geo_file)

; Read data field using the clues from print(eos_file) output.
  data_raw = eos_file->EV_1KM_Emissive
; print(data_raw)

; Filter out invalid values and set them as fill value.
  data_valid = where(data_raw.gt.data_raw@valid_range(0) .and. data_raw.lt.data_raw@valid_range(1), data_raw, data_raw@_FillValue);

  data_valid@_FillValue = data_raw@_FillValue
  dataf = (data_valid - data_raw@radiance_offsets(0)) * data_raw@radiance_scales(0)
  
; Subset data.
  data = dataf(0,:,:)
  
; Asociate longitude and latitude using the clues from the output of 
; print(geo_file) command.
  data@lat2d = geo_file->Latitude 
  data@lon2d = geo_file->Longitude  
  dname = "~C~at " + data_raw!0 + "=0"
  data@long_name = "Radiance derived from " + data_raw@long_name + dname
  data@units = data_raw@radiance_units ; set unit attribute.

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
  
; Set limits on map for zoom-in effect.  
;  res@mpLimitMode = "LatLon"
;  res@mpMinLatF	= min(data@lat2d)
;  res@mpMaxLatF	= max(data@lat2d)
;  res@mpMinLonF	= min(data@lon2d)
;  res@mpMaxLonF	= max(data@lon2d)
  
  res@mpGridAndLimbOn     = True ; Put Grid lines

; Change map center.
  res@mpCenterLonF        = avg(data@lon2d)
  res@mpCenterLatF        = avg(data@lat2d)
  res@mpFillOn = False

; Show latitude values.
  res@pmTickMarkDisplayMode = "Always"
  
  res@tiMainString = file_name
  res@trGridType = "TriangularMesh"
  plot = gsn_csm_contour_map(xwks,data,res)
end
