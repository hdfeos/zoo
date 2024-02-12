; 
;  This example code illustrates how to access and visualize
;  LP DAAC MOD11C2 v6 HDF-EOS2 Grid file using NCL. 
;
;  If you have any questions, suggestions, comments  on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Tested under: NCL 6.4.0
; Last updated: 2018-04-16 


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; This is an example of a 2-D grid file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin

  eos_file = addfile("MOD09GA.A2007268.h10v08.005.2007272184810.hdf", "r") ; Read file for the first time. 
  he2_file = addfile("MOD09GA.A2007268.h10v08.005.2007272184810.hdf.he2", "r") ; Read file for the second time to efficiently obtain lat and lon. 

; List available fields and attributes. 
; print(eos_file)

; read data field
  data_raw = eos_file->Range_1 

; print(data_raw)

; Filter out invalid values and set them as fill value. 
  data_valid = where(data_raw.gt.data_raw@valid_range(0) .and. data_raw.lt.data_raw@valid_range(1), data_raw, data_raw@_FillValue)

; Apply scale factor according to the field attribute   
; correct_data_value = (raw_data_value - offset)/scale
; from HDFView, there is no offset
  data = data_valid/data_raw@scale_factor 

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
  data@lat2d = he2_file->GridLat_MODIS_Grid_1km_2D
  data@lon2d = he2_file->GridLon_MODIS_Grid_1km_2D

; Open workstation
  xwks = gsn_open_wks("pdf","MOD09GA.A2007268.h10v08.005.2007272184810_Range_1_zoom.ncl") ; open workstation

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

  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
  res@mpMaxLatF	= max(data@lat2d) ; 
  res@mpMinLonF	= min(data@lon2d) ;
  res@mpMaxLonF	= max(data@lon2d) ;

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
  res@tiMainString = "MOD09GA.A2007268.h10v08.005.2007272184810.hdf" ; create title
  res@gsnLeftString = "Field name: " + data@long_name
  res@gsnRightString = "Units: " + data@units

  plot = gsn_csm_contour_map_ce(xwks,data,res) ; create plot

; cleaning up used resources
  delete(plot)
  delete(xwks)
  delete(data_raw)
  delete(data_valid)
  delete(data)
  delete(res)
  delete(he2_file)
  delete(eos_file)

end