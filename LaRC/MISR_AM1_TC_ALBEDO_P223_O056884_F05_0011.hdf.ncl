; 
;  This example code illustrates how to access and visualize LaRC MISR
; AM1 TC ALBEDO HDF-EOS2 SOM Grid file in NCL. 
;
;  If you have any questions, suggestions, comments  on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; $ncl MISR_AM1_TC_ALBEDO_P223_O056884_F05_0011.hdf.ncl
;
; Tested under: NCL 6.4.0
; Last updated: 2018-08-16

begin
  file_name = "MISR_AM1_TC_ALBEDO_P223_O056884_F05_0011.hdf"

; Read file. 
; To read file as an HDF-EOS2 file, .he2 is appended to the file name.
; For more information, consult section 4.3.2 of [1]
  eos_file = addfile(file_name+".he2", "r")

; Read dataset with subsetting.
  data = eos_file->AlbedoLocal_ReflectingLevelParameters_2_2_km(50,:,:,0)

; The file contains SOM projection. 
; We need to use eos2dump to generate lat and lon.
; For information on how to obtain the lat/lon data, check [2].
  dimsize = dimsizes(data)
  nlon = dimsize(0)  
  nlat = dimsize(1)  
  lat_file_name = "lat_MISR_AM1_TC_ALBEDO_P223_O056884_F05_0011.output"
  data@lat2d = asciiread(lat_file_name,(/nlon,nlat/),"float")
  lon_file_name = "lon_MISR_AM1_TC_ALBEDO_P223_O056884_F05_0011.output"
  data@lon2d = asciiread(lon_file_name,(/nlon,nlat/),"float")
  data@long_name = "AlbedoLocal at SOMBlockDim=50 NBandDim=0"
  data@units = "No Unit"

; Open workstation.
  xwks = gsn_open_wks("png", file_name+".ncl") 

  res = True 
  res@cnFillOn = True ; Enable contour fill.
  res@gsnMaximize = True ; Make plot large.
  res@gsnPaperOrientation = "portrait" 
  res@cnLinesOn = False ; Turn off contour lines.
  res@cnLineLabelsOn  =  False ; Turn off contour line labels.
  res@gsnSpreadColors = True ; Use the entire color spectrum.
  res@cnFillMode = "RasterFill" ; Fill faster.
  res@lbOrientation = "vertical" ; Set labels vertical.
  res@cnMissingValFillPattern  =  0 ; Set missing value pattern to SolidFill.
  res@cnMissingValFillColor = 0 ; Use white color for missing values.
  res@lbLabelAutoStride = True ; Ensure no label overlap.
  res@tiMainString = file_name
  res@gsnLeftStringFontHeightF = 9 ; Make text smaller.
  res@gsnRightStringFontHeightF = 9
  res@mpLimitMode = "LatLon"

; Set limits of map, based on the min/max of the dataset latitude/longitude
  res@mpMinLatF	= min(data@lat2d)
  res@mpMaxLatF	= max(data@lat2d)
  res@mpMinLonF	= min(data@lon2d)
  res@mpMaxLonF	= max(data@lon2d)

; Define colormap.
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") 

; Plot data.
  plot = gsn_csm_contour_map_ce(xwks,data,res)
end

; Reference
;
; [1] http://hdfeos.org/software/ncl.php.
; [2] http://hdfeos.org/zoo/note_non_geographic.php