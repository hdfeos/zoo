;
;  This example code illustrates how to access and visualize 
; LP DAAC MCD19A2 HDF-EOS2 Sinusoidal Grid file using NCL. 
;
;  If you have any questions, suggestions, comments on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; 
; Usage:save this script and run 
; 
; $ncl MCD19A2.A2010010.h25v06.006.2018047103710.hdf.ncl
;

; Tested under: NCL 6.6.2
; Last Updated: 2019-05-23
begin
  file_name = "MCD19A2.A2010010.h25v06.006.2018047103710.hdf"
  
; Read file as HDF-EOS2 file to obtain lat and lon.
  he2_file = addfile(file_name + ".he2", "r") 
  print(he2_file)
  
; Read a specific variable.
  data_raw = he2_file->Optical_Depth_055_grid1km(0,:,:)

; Filter out invalid range values and fill values.
  data_valid = where(data_raw.gt.data_raw@valid_range(0) .and. data_raw.lt.data_raw@valid_range(1), data_raw, data_raw@_FillValue)
  data_valid@_FillValue = data_raw@_FillValue    

; Apply scale factor.
  data = (data_valid - data_raw@add_offset) * data_raw@scale_factor


; Copy attributes.
  data@long_name = data_raw@long_name
  data@units = data_raw@unit

; Associate longitude and latitude.
  data@lat2d = he2_file->GridLat_grid1km
  data@lon2d = he2_file->GridLon_grid1km

  xwks = gsn_open_wks("png", file_name + ".ncl" ) ; open workstation 

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
  res@trGridType="TriangularMesh"

; The following 5 lines are used to create a zoomed image.
; Set limits of map, based on the min/max of the dataset latitude/longitude
  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d) 
  res@mpMaxLatF	= max(data@lat2d)  
  res@mpMinLonF	= min(data@lon2d) 
  res@mpMaxLonF	= max(data@lon2d) 

; Define colormap.
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") 

; Create title.
  res@tiMainString=file_name 

  plot = gsn_csm_contour_map_ce(xwks,data,res) 
end