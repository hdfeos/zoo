;  This example code illustrates how to access and visualize LaRC MISR Grid 
; file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums).
;
;   If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;

; Tested under: NCL 6.0.0
; Last updated: 2011-10-03

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  file_name= "MISR_AM1_GRP_ELLIPSOID_GM_P117_O058421_BA_F03_0024.hdf"

; Read file.
; To read HDF-EOS2 files, .he2 is appended to the argument. 
; For more information, consult section 4.3.2 of [1].
  eos_file=addfile(file_name+".he2", "r") 

; The geolocation values are stored in a secondary file.
; Read geolocation file.
  geo_file=addfile("MISR_AM1_AGP_P117_F01_24.hdf.he2", "r")

; Read data field.
; NCL reads the data as integer.
  data3D_raw = eos_file->Blue_Radiance_RDQI_BlueBand

; We need to convert the data to unsigned because NCL reads as signed 
; integer. The original type is "uint16".
  data3D = tounsigned(data3D_raw)


; We need to shift bits for RDQI to get blue band only. 
; See the page 84 of "MISR Data Products Specifications (rev. S)".
; The document is available at [2].
; NCL doesn't have bitshift operator so we divide the unsigned integer value
; by 4.
  data3Ds = data3D / 4;

; Filter out values (> 16376) used for "Flag Data".
; See Table 1.2 in "Level 1 Radiance Scaling and Conditioning
; Algorithm  Theoretical Basis" document [3].
  data3Ds = where(data3Ds.gt.16376, data3Ds@_FillValue, data3Ds);

; Convert 3-D data to 2-D data by subsetting at block=50.
  data2D = tofloat(data3Ds(50,:,:))

; Associate longitude and latitude.
  data2D@lat2d=geo_file->GeoLatitude_Standard(50,:,:) 
  data2D@lon2d=geo_file->GeoLongitude_Standard(50,:,:) 

; Apply scale factor. 
  data2D = data2D * stringtofloat(eos_file@Scale_factor_BlueBand)

; See NCL function code [4] and equations [5] pages on how to do subscripts, 
; superscripts, and greek characters.
;
; A number after the B or S indicates the level of the sub/superscript
; An "N" returns you back to "normal" level.
; 
; We assume that "*TextFuncCode: ~" is defined in your ~/.hluresfile file.
  data2D@unit = "Wm~S~-2~N~sr~S~-1~N~" + "~F8~m~N~" + "~F21~m~S~-1~N~"
  data2D@long_name = "Blue_Radiance at SOMBlockDim=50"


  xwks=gsn_open_wks("pdf","MISR_AM1_GRP_ELLIPSOID_GM_P117_O058421_BA_F03_0024_Blue_Radiance_RDQI_lvl50_AGP.ncl") ; open workstation

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

  res@tiMainString=file_name ; create title
  plot=new(2, "graphic") ; allocate plot

  plot(0)=gsn_csm_contour_map_ce(xwks,data2D,res) ; plot on world map first

  delete(res@tiMainString) ; delete title for subsequent plots


  res@mpLimitMode         = "LatLon"
; Set limits of map, based on the min/max of the dataset latitude/longitude
  res@mpMinLatF	= min(data2D@lat2d) 
  res@mpMaxLatF	= max(data2D@lat2d) 
  res@mpMinLonF	= min(data2D@lon2d) 
  res@mpMaxLonF	= max(data2D@lon2d) 


  plot(1)=gsn_csm_contour_map_ce(xwks,data2D,res) ; 


; Clean up resources.
  delete(plot) 
  delete(res)
  delete(xwks)
  delete(data2D)
  delete(data3Ds)
  delete(data3D)
  delete(geo_file)
  delete(eos_file)
end

; Reference
;
; [1] http://hdfeos.org/software/ncl.php
; [2] https://asdc.larc.nasa.gov/documents/misr/DPS_v50_RevS.pdf
; [3] https://eospso.gsfc.nasa.gov/atbd-category/45
; [4] http://www.ncl.ucar.edu/Applications/fcodes.shtml
; [5] http://www.ncl.ucar.edu/Applications/eqn.shtml
