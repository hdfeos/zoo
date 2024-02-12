;This example code illustrates how to access and visualize LP_DAAC_MYD swath file in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 2-D swath file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin

  eos_file = addfile("MYD11_L2.A2007093.0735.005.2007101061952.hdf", "r") ; Read file. 

  geo_file = addfile("MYD03.A2007093.0735.005.2009281140106.hdf.he2", "r") ; Read geolocation file.
  ; Because dimension maps are used in the eos_file, we must use geolocation values that are stored in a secondary file.

  data_raw = eos_file->LST ; read data field

; Filter out invalid values and set them as fill value. 
  data_valid = where(data_raw.gt.data_raw@valid_range(0) .and. data_raw.lt.data_raw@valid_range(1), data_raw, data_raw@_FillValue)

; Apply scale factor according to the field attribute   
; correct_data_value = raw_data_value * scale 
  data = data_valid * data_raw@scale_factor 

; NCL contour doesn't allow 0.0 for _FillValue.   
; See http://www.ncl.ucar.edu/Support/talk_archives/2010/0730.html  
; Thus, we cannot use the attribute value directly like below because it is 0.  
; data@_FillValue = data_raw@_FillValue 

; Instead, let's use default fill values for double type.  
; See http://www.ncl.ucar.edu/Document/Manuals/Ref_Manual/NclVariables.shtml  
; From NCL 6.0.0, it should be 9.969209968386869e+36  
  data@_FillValue = -9999.0 

  data@long_name = data_raw@long_name
  data@units = data_raw@units

; Associate longitude and latitude
  data@lat2d = geo_file->Latitude_MODIS_Swath_Type_GEO(:,:) ; associate longitude and latitude
  data@lon2d = geo_file->Longitude_MODIS_Swath_Type_GEO(:,:) ; 

; open workstation
  xwks = gsn_open_wks("pdf","MYD11_L2.A2007093.0735.005.2007101061952_LST.ncl") 

  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True ; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn = False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@lbOrientation = "vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0 ; white color for missing values
  res@lbLabelAutoStride = True ; ensure no label overlap

  ; the following 5 sentences are used to generate zoom plot
  ; res@mpLimitMode = "LatLon"
  ; res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
  ; res@mpMaxLatF	= max(data@lat2d) ; 
  ; res@mpMinLonF	= min(data@lon2d) ;
  ; res@mpMaxLonF	= max(data@lon2d) ;

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  res@tiMainString = "MYD11_L2.A2007093.0735.005.2007101061952.hdf" ; create title
  res@gsnLeftString = "Field name: " + data@long_name
  res@gsnRightString = "Units: " + data@units

  plot = gsn_csm_contour_map_ce(xwks,data,res) ; create plot

  delete(plot) ; cleaning up used resources
  delete(data_raw)
  delete(data_valid)
  delete(data)
  delete(xwks)
  delete(res)
  delete(eos_file)
  delete(geo_file)

end