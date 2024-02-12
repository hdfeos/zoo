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
  file_name = "MYD021KM.A2002226.0000.005.2009193222735.hdf"

; To read the file as an HDF-EOS2 file, .he2 is appended to the argument. 
; For more information, consult section 4.3.2 of [1]. 
  eos_file = addfile(file_name+".he2", "r")

; Uncomment the following line to print all variables and attributes.
;  print(eos_file)


; Rad the same file as an HDF4 file to retrieve attributes.
  hdf4_file = addfile(file_name, "r")

; Uncomment to the following line to print all variables and attributes.
;  print(hdf4_file)

; Read geolocation file.
; Since dimension maps are used in the eos_file, we must use geolocation
; values that are stored in a secondary file.
  geo_file=addfile("MYD03.A2002226.0000.005.2009193071127.hdf.he2", "r")

; Read data field.
; In order to read the EV_1KM_Emissive data field from the HDF-EOS2 file, 
; the group under which the data field is placed must be appended to the data 
; field in NCL. For more information, visit section 4.3.2 of [1].
  data_unsigned=eos_file->EV_1KM_Emissive_MODIS_SWATH_Type_L1B
  data_hdf4 = hdf4_file->EV_1KM_Emissive
  data_unsigned@_FillValue = data_hdf4@_FillValue

; Filter out invalid values and set them as fill value.
  data_valid=where(data_unsigned.gt.data_hdf4@valid_range(0) .and. data_unsigned.lt.data_hdf4@valid_range(1), data_unsigned, data_unsigned@_FillValue)

; Subset data.
  data_unscaled   = data_valid(0,:,:)
  data_unscaled_1 = data_valid(5,:,:)
  data_unscaled_2 = data_valid(10,:,:)
  data_unscaled_3 = data_valid(15,:,:)

; Apply scale factor and offset according to [2].
; There are 16 scale and offset pairs from EV_1KM_Emissive's attributes:
;    radiance_scales and radiance_offsets,
  data = (data_unscaled - data_hdf4@radiance_offsets(0)) * data_hdf4@radiance_scales(0)
  data_1 = (data_unscaled_1 - data_hdf4@radiance_offsets(5)) * data_hdf4@radiance_scales(5)
  data_2 = (data_unscaled_2 - data_hdf4@radiance_offsets(10)) * data_hdf4@radiance_scales(10)
  data_3 = (data_unscaled_3 - data_hdf4@radiance_offsets(15)) * data_hdf4@radiance_scales(15)

; Associate longitude and latitude.
  data@lat2d=geo_file->Latitude_MODIS_Swath_Type_GEO(:,:)
  data@lon2d=geo_file->Longitude_MODIS_Swath_Type_GEO(:,:)  


  data_1@lat2d=geo_file->Latitude_MODIS_Swath_Type_GEO(:,:)  
  data_1@lon2d=geo_file->Longitude_MODIS_Swath_Type_GEO(:,:)  


  data_2@lat2d=geo_file->Latitude_MODIS_Swath_Type_GEO(:,:)  
  data_2@lon2d=geo_file->Longitude_MODIS_Swath_Type_GEO(:,:)  


  data_3@lat2d=geo_file->Latitude_MODIS_Swath_Type_GEO(:,:)  
  data_3@lon2d=geo_file->Longitude_MODIS_Swath_Type_GEO(:,:)  

; The plot is derived using the radiance offsets and scales according to [2].
; Thus, add a more descriptive field name.
  data@long_name = "Radiance derived from " + data_hdf4@long_name + "~C~at " + data_hdf4!0 + "=0"
  data@units = data_hdf4@radiance_units

  data_1@long_name = "Radiance derived from " + data_hdf4@long_name + "~C~at " + data_hdf4!0 + "=5"
  data_1@units = data_hdf4@radiance_units

  data_2@long_name = "Radiance derived from " + data_hdf4@long_name + "~C~at " + data_hdf4!0 + "=10"
  data_2@units = data_hdf4@radiance_units

  data_3@long_name = "Radiance derived from " + data_hdf4@long_name + "~C~at " + data_hdf4!0 + "=15"
  data_3@units = data_hdf4@radiance_units

  xwks=gsn_open_wks("pdf","MYD021KM.A2002226.0000.005.2009193222735_EV_1KM_Emissive.ncl") ; open workstation

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


  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

; Create title.
  res@tiMainString=file_name
  plot=new(5, "graphic") ; allocate plot
  res@gsnLeftStringFontHeightF=9 ; make text smaller
  res@gsnRightStringFontHeightF=9

  plot(0)=gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first

  delete(res@tiMainString) ; delete title for subsequent plots


  res@mpLimitMode         = "LatLon"
  res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
  res@mpMaxLatF	= max(data@lat2d) ; 
  res@mpMinLonF	= min(data@lon2d) ;
  res@mpMaxLonF	= max(data@lon2d) ;
  plot(1)=gsn_csm_contour_map_ce(xwks,data,res)  
  plot(2)=gsn_csm_contour_map_ce(xwks,data_1,res)
  plot(3)=gsn_csm_contour_map_ce(xwks,data_2,res)
  plot(4)=gsn_csm_contour_map_ce(xwks,data_3,res)


  delete(plot) ; cleaning up resources used
  delete(xwks)
  delete(data_unsigned)
  delete(data_valid)
  delete(data_unscaled)
  delete(data_unscaled_1)
  delete(data_unscaled_2)
  delete(data_unscaled_3)
  delete(data)
  delete(data_1)
  delete(data_2)
  delete(data_3)
  delete(res)
  delete(geo_file)
  delete(eos_file)
end

; References
;
; [1] http://hdfeos.org/software/ncl.php
; [2] MODIS Level 1B Product User's Guide:
;     http://mcst.gsfc.nasa.gov/uploads/files/M1054_RevC_PUG_022709_Update.pdf
