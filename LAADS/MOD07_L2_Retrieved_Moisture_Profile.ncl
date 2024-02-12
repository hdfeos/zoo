;   This example code illustrates how to access and visualize LAADS_MOD swath 
; file in NCL. If you have any questions, suggestions, comments  on this 
; example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;   If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).



load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

; This is an NCL example of visualizing a 3-D dataset in MOD07_L2 product file 
; at various levels. 
; 
; Please visit http://modis-atmos.gsfc.nasa.gov/MOD07_L2/format.html to know
; the basics about the file format and how to apply scale and offset values on
; each dataset.
;

begin
; Read file. 
  filename = "MOD07_L2.A2010001.0000.005.2010004001518.hdf"
  eos_file = addfile(filename, "r") 

; Print information about the file to know 
; what variables and attributes are available for plotting.
  print(eos_file);

; Read "Retrieved_Moisture_Profile" data field.
  data_unscaled=eos_file->Retrieved_Moisture_Profile

; Print information about the specific dataset to check scale and offset.
  printVarSummary(data_unscaled)

; Apply offset and scale using the formula in
; http://modis-atmos.gsfc.nasa.gov/MOD07_L2/format.html. 
; Here, we pick the level 5.
  data =  data_unscaled@scale_factor * \
  (data_unscaled(5,:,:) -  data_unscaled@add_offset)

; Associate longitude and latitude.
  data@lat2d = eos_file->Latitude
  data@lon2d = eos_file->Longitude 

; Copy the unit from the original unit attribute of the dataset.
  data@units=data_unscaled@units

; Let's try different levels.
  data_1 = data_unscaled@scale_factor * \
  (data_unscaled(0,:,:) -  data_unscaled@add_offset) ; Level 0
  data_1@lat2d = eos_file->Latitude
  data_1@lon2d = eos_file->Longitude 
  data_1@units = data_unscaled@units

  data_2 = data_unscaled@scale_factor * \
  (data_unscaled(10,:,:) -  data_unscaled@add_offset) ; Level 10
  data_2@lat2d = eos_file->Latitude
  data_2@lon2d = eos_file->Longitude
  data_2@units = data_unscaled@units

  data_3 = data_unscaled(14,:,:)*0.009999999776482582 ; Level 14
  data_3@lat2d = eos_file->Latitude
  data_3@lon2d = eos_file->Longitude
  data_3@units = data_unscaled@units


  xwks=gsn_open_wks("pdf","MOD07_L2.A2010001.0000.005.2010004001518_Retrieved_Moisture_Profile") ; open workstation

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

  res@gsnCenterStringFontHeightF=10 ; make font smaller


  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap


  res@tiMainString=filename ; create title
  plot=new(5, "graphic") ; allocate plot
  res@gsnCenterString = data_unscaled@long_name + " at " + data_unscaled!0 + "=5" ; create center string using long name and dimension name.
  plot(0)=gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first
  delete(res@tiMainString) ; delete title for subsequent plots


  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
  res@mpMaxLatF	= max(data@lat2d)  
  res@gsnPolar = "SH" ; plot southern hemisphere
  res@gsnCenterString = data_unscaled@long_name + " at " + data_unscaled!0 + "=5"
  plot(1)=gsn_csm_contour_map_polar(xwks,data,res) ;
  
  res@gsnCenterString= data_unscaled@long_name + " at " + data_unscaled!0 + "=0"
  plot(2)=gsn_csm_contour_map_polar(xwks,data_1,res)

  res@gsnCenterString= data_unscaled@long_name + " at " + data_unscaled!0 + "=10"
  plot(3)=gsn_csm_contour_map_polar(xwks,data_2,res)

  res@gsnCenterString= data_unscaled@long_name + " at " + data_unscaled!0 + "=14"
  plot(4)=gsn_csm_contour_map_polar(xwks,data_3,res)


; Clean up resources used.
  delete(plot) 
  delete(xwks)
  delete(data_unscaled)
  delete(data)
  delete(data_1)
  delete(data_2)
  delete(data_3)
  delete(res)
  delete(eos_file)
end



