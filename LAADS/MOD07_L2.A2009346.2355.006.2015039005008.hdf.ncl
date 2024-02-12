; 
; This example code illustrates how to access and visualize LAADS MODIS Swath
; HDF-EOS2 file in NCL.
;
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Usage:save this script and run 
; 
; $ncl MOD07_L2.A2009346.2355.006.2015039005008.hdf.ncl
;
; Tested under: NCL 6.4.0
; Last updated: 2018-02-15

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; Read data file.
  file_name="MOD07_L2.A2009346.2355.006.2015039005008.hdf"
  
; To read HDF-EOS2 files, .he2 is appended to the file name.
; For more information, consult section 4.3.2 of [1].
  eos_file=addfile(file_name+".he2", "r")
; print(eos_file)

; Read "Retrieved_Moisture_Profile" data field.
  data_unscaled=eos_file->Retrieved_Moisture_Profile_mod07

; Print information about the specific dataset to check scale and offset.
;  printVarSummary(data_unscaled)

; Apply offset and scale using the formula in
; http://modis-atmos.gsfc.nasa.gov/MOD07_L2/format.html. 
; Here, we pick the level 5.
  data =  data_unscaled@scale_factor * \
  (data_unscaled(5,:,:) -  data_unscaled@add_offset)

; Associate longitude and latitude.
  data@lat2d = eos_file->Latitude_mod07
  data@lon2d = eos_file->Longitude_mod07

; Copy the unit/long_name from the original unit attribute of the dataset.
  data@units=data_unscaled@units
  data@long_name=data_unscaled@long_name+" at " + data_unscaled!0 + "=5"
  
  xwks = gsn_open_wks("png", file_name + ".ncl") ; open workstation

  res = True ; plot mods desired
  
  res@cnFillOn = True ; enable contour fill
  res@cnFillMode = "RasterFill" ; faster
  res@cnLineLabelsOn = False ; turn off contour line labels  
  res@cnLinesOn = False ; turn off contour lines
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0 ; white color for missing values
  
  res@gsnMaximize = True ; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@gsnLeftStringFontHeightF = 11 ; make font smaller
  res@gsnRightStringFontHeightF = 11 ; make font smaller

  res@lbOrientation = "vertical" ; vertical labels
  res@lbLabelAutoStride = True ; ensure no label overlap

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") 
  res@mpProjection = "Orthographic"
  res@mpLimitMode = "LatLon"
  
; Uncomment the following to set limits of map.
;  res@mpMinLatF	= min(data@lat2d)
;  res@mpMaxLatF	= max(data@lat2d)
;  res@mpMinLonF	= min(data@lon2d)
;  res@mpMaxLonF	= max(data@lon2d)
  res@mpGridAndLimbOn     = True ; Put Grid lines
; Change map center.
  res@mpCenterLonF        = avg(data@lon2d)
  res@mpCenterLatF        = avg(data@lat2d)

; Show latitude values.
  res@pmTickMarkDisplayMode = "Always"
  
  res@tiMainString = file_name
  res@trGridType = "TriangularMesh"
  
  plot = gsn_csm_contour_map(xwks,data,res)
  
; Clean up resources used.
  delete([/plot, res, xwks, data, eos_file/])
end

; References
;
; [1] http://hdfeos.org/software/ncl.php.