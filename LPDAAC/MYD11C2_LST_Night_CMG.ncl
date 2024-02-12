;This example code illustrates how to access and visualize LP_DAAC_MYD Grid file in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; This is an example of a 2-D grid file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin

; Read dataset file. 
  eos_file=addfile("MYD11C2.A2006337.004.2006348062459.hdf", "r")

; List available fields and attributes. 
; print(eos_file)

; read data field
  data_raw = eos_file->LST_Night_CMG

; print (data_raw)

; Filter out invalid values and set them as fill value. 
  data_valid=where(data_raw.gt.data_raw@valid_range(0) .and. data_raw.lt.data_raw@valid_range(1), data_raw, data_raw@_FillValue)

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
  data@_FillValue=-9999.0

  data@long_name = data_raw@long_name
  data@units = data_raw@units

; Associate longitude and latitude
  data!0="lat" ; This file contains coordinate variables that will not properly plot. 
  data!1="lon" ; To properly display the data, the latitude/longitude must be remapped.
; See http://www.ncl.ucar.edu/Applications/Scripts/regrid_10.ncl for more information

  lat=latGlobeFo(3600, "lat", "latitude", "degrees_north") 
  lon=lonGlobeFo(7200, "lon", "longitude", "degrees_east")

  lat=lat(::-1) ; use north-to-south latitude ordering
  lon=(/ lon - 180. /) ; Span 180W to 180E instead of 0 to 360
  lon&lon=lon ; update longitude

  data&lat=lat
  data&lon=lon

; open workstation
  xwks=gsn_open_wks("pdf","MYD11C2.A2006337.004.2006348062459_LST_Night_CMG.ncl") 

  setvalues NhlGetWorkspaceObjectId() ; make maximum filesize larger
  "wsMaximumSize" : 200000000
  end setvalues

  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@cnLinesOn=False ; turn off contour lines
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbLabelAutoStride=True ; ensure labels do not overlap
  res@lbOrientation = "vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0; white color for missing values

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  res@tiMainString="MYD11C2.A2006337.004.2006348062459.hdf" ; create title
  res@gsnLeftString = "Field name: " + data@long_name
  res@gsnRightString = "Units: " + data@units

  plot=gsn_csm_contour_map_ce(xwks,data,res) ; create plot

; cleaning up used resources
  delete(plot)
  delete(data)
  delete(data_valid)
  delete(data_raw)
  delete(xwks)
  delete(res)
  delete(eos_file)

end












