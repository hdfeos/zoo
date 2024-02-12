;  This example code illustrates how to access and visualize LAADS_MYD swath 
; file in NCL. 
;
; If you have any questions, suggestions, comments  on this example,
;  please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
; If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.0.0
; Last updated: 2011-09-26 

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  file_name = "MYD02HKM.A2010031.0035.005.2010031183706.hdf"
  eos_file=addfile(file_name + ".he2", "r")

; Uncomment the following line to print all variables and attributes.
;  print(eos_file)

; Rad the same file as an HDF4 file to retrieve attributes.
  hdf4_file = addfile(file_name, "r")

; Uncomment to the following line to print all variables and attributes.
;  print(hdf4_file)

; Read data field.
; In order to read the from the HDF-EOS2 file, 
; the group under which the data field is placed must be appended to the data 
; field in NCL. For more information, visit section 4.3.2 of [1].
  data_unscaled = eos_file->EV_500_RefSB_MODIS_SWATH_Type_L1B(0,:,:) 
  data_hdf4 = hdf4_file->EV_500_RefSB
  data_unscaled@_FillValue =  data_hdf4@_FillValue

; Filter out invalid values and set them as fill value.
  data_valid=where(data_unscaled.gt.data_hdf4@valid_range(0) .and. data_unscaled.lt.data_hdf4@valid_range(1), data_unscaled, data_unscaled@_FillValue)

; Apply scale factor and offset according to [2].
  data = (data_unscaled - data_hdf4@reflectance_offsets(0)) * data_hdf4@reflectance_scales(0)

  dimsize=dimsizes(data)
  nlon=dimsize(0) 
  nlat=dimsize(1) 

; We need to use eosdump to generate lat and lon
; For information on how to obtain the lat/lon data, check [3].
; To properly display the data, the latitude/longitude must be remapped.
  lat=asciiread("lat_MYD02HKM.A2010031.0035.005.2010031183706.output",(/nlon,nlat/),"float")
  lon=asciiread("lon_MYD02HKM.A2010031.0035.005.2010031183706.output",(/nlon,nlat/),"float")

  data@lat2d=lat
  data@lon2d=lon


; The plot is derived using the reflectance offset and scale according to [2]. 
; Thus, add a more descriptive field name.
  data@long_name = "Reflectance derived from~C~" + data_hdf4@long_name + "~C~at " + data_hdf4!0 + "=0"
  data@units = data_hdf4@reflectance_units

  xwks=gsn_open_wks("pdf","MYD02HKM.A2010031.0035.005.2010031183706_EV_500_RefSB.ncl")   ; open workstation

  setvalues NhlGetWorkspaceObjectId() ; make maximum filesize larger
  "wsMaximumSize" : 200000000
  end setvalues

  res=True ;plot mods desired
  res@cnFillOn=True   ;enable contour fill
  res@gsnMaximize=True   ;make plot large
  res@gsnPaperOrientation = "portrait"    ;force prtrait orientation
  res@cnLinesOn=False   ;turn off contour line
  res@cnLineLabelsOn =  False    ;turn off contour line labels
  res@gsnSpreadColors=True    ; use the entire color spectrum
  res@cnFillMode="RasterFill"   ;faster
  res@lbOrientation="vertical"  ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0; white color for missing values
  res@lbLabelAutoStride = True   ; ensure no label overlap
  res@mpMaxLatF	= max(data@lat2d) ; limit the latitude for zoomed in image.

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")   ; define colormap
  res@tiMainString   = "MYD02HKM.A2010031.0035.005.2010031183706.hdf"

  res@gsnPolar = "SH" ; specify the hemisphere
  plot=gsn_csm_contour_map_polar(xwks,data,res)

  delete(plot)
  delete(xwks)
  delete(data)
  delete(res)
  delete(eos_file)
end

; References
;
; [1] http://hdfeos.org/software/ncl.php
; [2] MODIS Level 1B Product User's Guide:
;     http://mcst.gsfc.nasa.gov/uploads/files/M1054_RevC_PUG_022709_Update.pdf
; [3]  http://hdfeos.org/zoo/note_non_geographic.php