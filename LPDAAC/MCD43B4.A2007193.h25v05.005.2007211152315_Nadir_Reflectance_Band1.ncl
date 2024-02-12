;This example code illustrates how to access and visualize LP_DAAC_MCD Grid file in NCL. 
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

  eos_file = addfile("MCD43B4.A2007193.h25v05.005.2007211152315.hdf", "r") ; Read file. 
  he2_file = addfile("MCD43B4.A2007193.h25v05.005.2007211152315.hdf.he2", "r") ; Read file for the second time to efficiently obtain lat and lon.

  data_raw = eos_file->Nadir_Reflectance_Band1 ; read specific subset of data field
; data_raw@_FillValue=32767h ; 'h' is appended to avoid type mismatching

; Apply scale factor according to the field attribute
; Scale factor=1E-4, given from the file
; In order to read the Nadir_Reflectance_Band1 data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.
  data = (data_raw - data_raw@add_offset) * data_raw@scale_factor

  data@_FillValue = (data_raw@_FillValue - data_raw@add_offset) * data_raw@scale_factor

  data@long_name = data_raw@long_name
  data@units = data_raw@units

; Associate longitude and latitude
  data@lat2d = he2_file->GridLat_MOD_Grid_BRDF ; associate latitude/longitude
  data@lon2d = he2_file->GridLon_MOD_Grid_BRDF

  xwks = gsn_open_wks("pdf","MCD43B4.A2007193.h25v05.005.2007211152315_Nadir_Reflectance_Band1_1lvl.ncl") ; open workstation 

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
; res@gsnLeftStringFontHeightF=10 ; make text smaller
; res@gsnCenterStringFontHeightF=10
; res@gsnRightStringFontHeightF=10

; the following 5 sentences are used to create a zoomed image
  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
  res@mpMaxLatF	= max(data@lat2d) ; 
  res@mpMinLonF	= min(data@lon2d) ;
  res@mpMaxLonF	= max(data@lon2d) ;

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap
  res@tiMainString="MCD43B4.A2007193.h25v05.005.2007211152315.hdf" ; create title
  res@gsnLeftString = "Field name: " + data@long_name
  res@gsnRightString = "Units: " + data@units
; res@gsnCenterString="Nadir_Reflectance_Band1" ; create center text

  plot = gsn_csm_contour_map_ce(xwks,data,res) 

; cleaning up used resources
  delete(plot) 
  delete(res)
  delete(xwks)
  delete(data)
  delete(data_raw)
  delete(eos_file)
  delete(he2_file)

end