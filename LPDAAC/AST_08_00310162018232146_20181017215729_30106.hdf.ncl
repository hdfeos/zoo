; 
; This example code illustrates how to access and visualize LP DAAC AST_08 v3
; HDF-EOS2 Swath file in NCL.
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
; $ncl AST_08_00310162018232146_20181017215729_30106.hdf.ncl
;
; Tested under: NCL 6.5.0
; Last updated: 2018-11-05
begin

; Read data file.
  file_name="AST_08_00310162018232146_20181017215729_30106.hdf"
  eos_file=addfile(file_name+".he2", "r")
  
; Remove comment to print the file content.
;  print(eos_file)

; Read data field.
  data = eos_file->KineticTemperature_SurfaceKineticTemperature

  dimsize=dimsizes(data)
  nlon=dimsize(0)
;  print(nlon)
  nlat=dimsize(1)
;  print(nlat)

; Create geolocation dataset from HDF-EOS2 dumper output.
;  
; Use the following command:
;
; $eos2dump -a1 AST_08_00310162018232146_20181017215729_30106.hdf SurfaceKineticTemperature > lat_AST_08_00310162018232146_20181017215729_30106.output
  lat=asciiread("lat_AST_08_00310162018232146_20181017215729_30106.output",(/nlon,nlat/),"float")
  
; Use the following command:
;
; $eos2dump -a2 AST_08_00310162018232146_20181017215729_30106.hdf SurfaceKineticTemperature > lon_AST_08_00310162018232146_20181017215729_30106.output
  lon=asciiread("lon_AST_08_00310162018232146_20181017215729_30106.output",(/nlon,nlat/),"float")

  data@lat2d=lat
  data@lon2d=lon
  
; See [1] for units and scale factor information.  
  dataf = 0.1 * data 
  dataf@units = "K"
  dataf@long_name = data@hdfeos_name
  dataf@lat2d=lat
  dataf@lon2d=lon
  
  xwks = gsn_open_wks("png", file_name + ".ncl") ; open workstation

  res = True ; plot mods desired
  
  res@cnFillOn = True ; enable contour fill
  res@cnFillMode = "RasterFill" ; faster
  res@cnLineLabelsOn = False ; turn off contour line labels  
  res@cnLinesOn = False ; turn off contour lines
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0 ; white color for missing values
  
  res@gsnMaximize = True ; make plot large
  res@gsnSpreadColors = True ; use the entire color spectrum

  res@lbOrientation = "vertical" ; vertical labels
  res@lbLabelAutoStride = True ; ensure no label overlap

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") 

  res@mpProjection = "Orthographic"
  res@mpLimitMode = "LatLon"
; Set limits of map.
  res@mpMinLatF	= min(lat)
  res@mpMaxLatF	= max(lat)
  res@mpMinLonF	= min(lon)
  res@mpMaxLonF	= max(lon)
  res@mpGridAndLimbOn     = True ; Put Grid lines
; Change map center.
  res@mpCenterLonF        = lon(nlon/2, nlat/2)
  res@mpCenterLatF        = lat(nlon/2, nlat/2)
  res@mpFillOn = False
  
; Show latitude values.
  res@pmTickMarkDisplayMode = "Always"
  
  res@tiMainString = file_name
  res@trGridType = "TriangularMesh"
  plot = gsn_csm_contour_map(xwks,dataf,res)
end

; References
; [1] https://asterweb.jpl.nasa.gov/content/03_data/01_Data_Products/release_surface_kinetic_temperatur.htm