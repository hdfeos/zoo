; 
; This example code illustrates how to access and visualize LAADS VNP09_NRT v1
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
; $ncl  VNP09_NRT.A2018064.0524.001.hdf.ncl
;
; Tested under: NCL 6.4.0
; Last updated: 2018-03-07

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
; Read data file.
  file_name="VNP09_NRT.A2018064.0524.001.hdf"


; To read HDF-EOS2 files, .he2 is appended to the file name.
; For more information, consult section 4.3.2 of [1].
  eos_file=addfile(file_name+".he2", "r")
; Print metadata information.
;  print(eos_file)  
  data_hdf4 = eos_file->375m_Surface_Reflectance_Band_I1_SurfReflect_VNP

; Rad the geo-location file [2].
  geo_file_name = "VNP03IMG_NRT.A2018064.0524.001.nc"  
  geo_nc4_file=addfile(geo_file_name, "r")
  
; Print metadata information.
;  print(geo_nc4_file)
  lat = geo_nc4_file->latitude
  lon = geo_nc4_file->longitude

; Set fill value.
; Data has multiple fill values.
; print(data_hdf4@FILL_VALUES)
  _FillValue = -28672
  data_valid=where(data_hdf4.eq.-994, _FillValue, data_hdf4)
  data_valid=where(data_hdf4.eq.-993, _FillValue, data_hdf4)
  data_valid=where(data_hdf4.eq.-992, _FillValue, data_hdf4)
  data_valid=where(data_hdf4.eq.-990, _FillValue, data_hdf4)
  data_valid=where(data_hdf4.eq.-100, _FillValue, data_hdf4)    
  data_valid@_FillValue = _FillValue

; Apply scale factor and offset according to the MODIS specification.
  data = (data_valid - data_hdf4@Offset) * data_hdf4@Scale


; Set unit [3] and long_name for plot.
  data@unit = "Reflectance"
  data@long_name = "375m Surface Reflectance Band I1"

; Associate lat/lon.
  data@lat2d = lat
  data@lon2d = lon

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

  
  res@tiMainString = file_name
  
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")
  res@mpProjection = "Orthographic"
  
; Set limits of map for zoom-in view.
  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d)
  res@mpMaxLatF	= max(data@lat2d)
  res@mpMinLonF	= min(data@lon2d)
  res@mpMaxLonF	= max(data@lon2d)
  
  res@mpGridAndLimbOn     = True ; Put Grid lines
; Change map center.
  dimsize=dimsizes(data)
  nlon=dimsize(0) 
  nlat=dimsize(1)
  res@mpCenterLonF = lon(nlon/2, nlat/2)
  res@mpCenterLatF = lat(nlon/2, nlat/2)
  res@mpFillOn = False

; Show latitude values.
  res@pmTickMarkDisplayMode = "Always"
  res@trGridType = "TriangularMesh"
  
  plot = gsn_csm_contour_map(xwks,data,res)
  
; Clean up resources used.
  delete([/data, data_hdf4/])
  delete([/plot, res, xwks, eos_file, geo_nc4_file/])
end

; References
;
; [1] http://hdfeos.org/software/ncl.php.
; [2] ftp://nrt3.modaps.eosdis.nasa.gov/allData/5001/VNP03IMG_NRT/
; [3] https://viirsland.gsfc.nasa.gov/PDF/VIIRS_Surf_Refl_UserGuide_v1.3.pdf