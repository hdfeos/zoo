; This example code illustrates how to access and visualize GESDISC_TRMM file in NCL. 
; If you have any questions, suggestions, comments  on this example, please use the HDF-EOS 
; Forum (http://hdfeos.org/forums). 
; If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not
; listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to 
; contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

  load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 3-D swath file data field at various levels.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

  begin

  eos_file=addfile("2A12.100402.70512.6.HDF", "r") ; Read file. 
; Since the file is not HDF-EOS2, it is not necessary to append .he2

  data_unscaled=eos_file->cldWater ; read data field
; Here, because the file is not HDF-EOS2, it is not necessary to append the group name

  data_unscaled@_FillValue=-9999h 

  data=data_unscaled(:,:,0) / data_unscaled@scale_factor + data_unscaled@add_offset
  data@lat2d=eos_file->geolocation(:,:,0); associate longitude and latitude
  data@lon2d=eos_file->geolocation(:,:,1); here, both longitude and latitude are stored in the same data field,
; but with different subsets.

  data_1=data_unscaled(:,:,5) / data_unscaled@scale_factor + data_unscaled@add_offset
  data_1@lat2d=eos_file->geolocation(:,:,0); 
  data_1@lon2d=eos_file->geolocation(:,:,1); 

  data_2=data_unscaled(:,:,7) / data_unscaled@scale_factor + data_unscaled@add_offset
  data_2@lat2d=eos_file->geolocation(:,:,0); 
  data_2@lon2d=eos_file->geolocation(:,:,1); 

  data_3=data_unscaled(:,:,10) / data_unscaled@scale_factor + data_unscaled@add_offset
  data_3@lat2d=eos_file->geolocation(:,:,0); 
  data_3@lon2d=eos_file->geolocation(:,:,1); 

  xwks=gsn_open_wks("pdf","2A12.100402.70512.6_cldWater.ncl") ; open workstation

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

  res@tiMainString="2A12.100402.70512.6.HDF" ; create title
  plot=new(5, "graphic") ; allocate plot
  res@gsnCenterString="cldWater at layer=0" ; create center text
  res@gsnRightString="g/m~S~-3~N~" ; create right text
  plot(0)=gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first
  delete(res@tiMainString) ; delete title for subsequent plots

  res@mpLimitMode = "LatLon"
  res@mpMinLatF = min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
  res@mpMaxLatF = max(data@lat2d) ; 
  res@mpMinLonF = min(data@lon2d) ;
  res@mpMaxLonF = max(data@lon2d) ;

  res@gsnCenterString="cldWater at layer=0" ; create center text
  plot(1)=gsn_csm_contour_map_ce(xwks,data,res) ; 

  res@gsnCenterString="cldWater at layer=5"
  plot(2)=gsn_csm_contour_map_ce(xwks,data_1,res)

  res@gsnCenterString="cldWater at layer=7"
  plot(3)=gsn_csm_contour_map_ce(xwks,data_2,res)

  res@gsnCenterString="cldWater at layer=10"
  plot(4)=gsn_csm_contour_map_ce(xwks,data_3,res)

  delete(plot) ; cleaning up resources used
  delete(xwks)
  delete(data)
  delete(data_1)
  delete(data_2)
  delete(data_3)
  delete(res)
  delete(eos_file)

  end

; References: 
; Range is 0.00 ~ 10.00 with unit g/m(-3).
; See http://disc.sci.gsfc.nasa.gov/precipitation/documentation/TRMM_README/TRMM_2A12_readme.shtml