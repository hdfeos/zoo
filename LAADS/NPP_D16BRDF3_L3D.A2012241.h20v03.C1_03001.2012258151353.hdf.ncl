;
;  This example code illustrates how to access and visualize 
; LAADS NPP VIIRS D16BRDF3 Sinusoidal Grid file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.0.0
; Last Updated: 2012-10-12

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  file_name = "NPP_D16BRDF3_L3D.A2012241.h20v03.C1_03001.2012258151353.hdf"
; Read file. 
; To read HDF-EOS2 files, .he2 is appended to the file name argument. 
; For more information, consult section 4.3.2 of [1].
; In NCL, reading the file as HDF-EOS2 can give you lat/lon information
; for SINUSOIDAL projection.
  eos_file=addfile(file_name+".he2", "r")

; Rad the file as an HDF4 file to retrieve not only data but also attributes.
  hdf4_file = addfile(file_name, "r")

; Uncomment the followings line to print all variables and attributes.
; print(eos_file)
; print(hdf4_file)

; Read data.
  data_hdf4=hdf4_file->Albedo_BSA_Band1
  printVarSummary(data_hdf4)

; Filter out invalid range values.
  data_valid = where(data_hdf4.gt.data_hdf4@valid_range(0) .and. data_hdf4.lt.data_hdf4@valid_range(1), data_hdf4, data_hdf4@_FillValue)

; Apply scale factor and offset.
  data = data_valid * data_hdf4@scale_factor + data_hdf4@add_offset

; Check type coercion is done properly.
  printVarSummary(data)

; Copy attributes for plotting.
  data@long_name = data_hdf4@long_name
  data@units = data_hdf4@units

; Check if _FillValue=0, which NCL doesn't allow.
  if(data_hdf4@_FillValue .eq. 0) then 
    data = where(data.eq.0, default_fillvalue("double"), data)
    data@_FillValue = default_fillvalue("double")
  end if 

; Check all attributes.
  printVarSummary(data);

; Get dimsizes to prepare lat/lon variables that will be associated with data.
  dimsize = dimsizes(data)
  nlon = dimsize(0)
  nlat = dimsize(1)

; Associate longitude and latitude
  data@lat2d=eos_file->GridLat_NPP_Grid_BRDF
  data@lon2d=eos_file->GridLon_NPP_Grid_BRDF

; Data preparation is done. Plot the data.
  xwks=gsn_open_wks("pdf", file_name + ".ncl") ; open workstation 
  gsn_define_colormap(xwks,"amwg")

  setvalues NhlGetWorkspaceObjectId() ; make maximum file size larger
  "wsMaximumSize" : 200000000
  end setvalues

  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@cnLinesOn=False ; turn off contour lines
  res@gsnMaximize=True ; use entire page
  res@gsnPaperOrientation="Portrait" ; force portrait
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbLabelAutoStride=True ; ensure labels do not overlap
  res@lbOrientation = "vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0; white color for missing values
  res@tiMainString=file_name 
  res@gsnLeftStringFontHeightF=12 ; make text smaller
  res@gsnRightStringFontHeightF=12
; Without the following statement, it will take too long.
  res@trGridType = "TriangularMesh" 

  plot = gsn_csm_contour_map_ce(xwks,data,res) ; create plot

  ; The next 5 statements are for a zoomed image.
  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
  res@mpMaxLatF	= max(data@lat2d) ; 
  res@mpMinLonF	= min(data@lon2d) ;
  res@mpMaxLonF	= max(data@lon2d) ;

  plot = gsn_csm_contour_map_ce(xwks,data,res) ; create plot

  delete(plot) ; cleaning up used resources
  delete(xwks)
  delete(data)
  delete(data_valid)
  delete(data_hdf4)
  delete(res)
  delete(hdf4_file)
end

; References
; [1] http://hdfeos.org/software/ncl.php.
