;
;  This example code illustrates how to access and visualize OBPG VIIRS L2
; HDF4 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please use
; the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Tested under: NCL 6.1.2
; Last updated: 2013-12-10
;
load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
; Since the file is not HDF-EOS2, it is not necessary to append .he2
  file_name = "V2013335180706.L2_NPP_OC.hdf"

; Read file. 
  hdf4_file=addfile(file_name, "r")

; List available fields and attributes.
 print(hdf4_file)

  data=hdf4_file->chlor_a
  lat=hdf4_file->latitude
  lon=hdf4_file->longitude
  data@_FillValue = data@bad_value_scaled

;  maxval=10.0
; The dataset contains high value like 400. 
; Set them as 
; data = where(data.gt.maxval, data, 10.0)

  data@lat2d=lat
  data@lon2d=lon


  xwks=gsn_open_wks("png", file_name+".ncl") ; open workstation

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

; The most values fall under 0.0 ~ 1.0 range. 
  res@cnLevelSelectionMode="ExplicitLevels";
  res@cnLevels=(/0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 1.0, 2.0, 4.0, 8.0, 16.0, 32.0/)

; Set limits of map, based on the min/max of the dataset latitude/longitude to
; get a zoomed image.
  res@mpLimitMode  = "LatLon"
  res@mpMinLatF = min(data@lat2d) 
  res@mpMaxLatF = max(data@lat2d)  
  res@mpMinLonF = min(data@lon2d) 
  res@mpMaxLonF = max(data@lon2d) 


  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

;  gsn_define_colormap(xwks,"hotres") ; define colormap
  res@tiMainString = file_name

  plot=gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first

;  Clean up resources.
  delete(plot)
  delete(xwks)
  delete(lat)
  delete(lon)
  delete(data)
  delete(res)
  delete(hdf4_file)
end