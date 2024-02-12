; 
;  This example code illustrates how to access and visualize
;  LP DAAC MOD09Q1 v6 HDF-EOS2 Grid file using NCL. 
;
;  If you have any questions, suggestions, comments  on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage:save this script and run 
; 
; $ncl MOD09Q1.A2007001.h31v08.006.2015126040724.hdf.ncl
; 
; Tested under: NCL 6.4.0
; Last updated: 2018-04-17 


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  file_name = "MOD09Q1.A2007001.h31v08.006.2015126040724.hdf"

; By adding .he2, NCL will open the file using HDF-EOS2 library instead of HDF4
; library. HDF-EOS2 library can resolve geo-location information automatically.
  he2_file = addfile(file_name+".he2", "r")
  
; List available fields and attributes.   
;  print(he2_file)

; Read data field and apply scale/offset.
  data = short2flt(he2_file->sur_refl_b01_MOD_Grid_250m_Surface_Reflectance)
  
; Associate longitude and latitude.
  data@lat2d = he2_file->GridLat_MOD_Grid_250m_Surface_Reflectance
  data@lon2d = he2_file->GridLon_MOD_Grid_250m_Surface_Reflectance

; Open workstation.
  xwks = gsn_open_wks("png", file_name+".ncl") 

  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn =  False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@lbOrientation = "vertical" ;vertical labels
  res@gsnLeftStringFontHeightF=18 ; make font smaller
  res@gsnRightStringFontHeightF=18 ; make font smaller
  
; Set limits of map, based on the min/max of the dataset latitude/longitude.
; This will create a zoom-in effect.  
  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d) 
  res@mpMaxLatF	= max(data@lat2d)  
  res@mpMinLonF	= min(data@lon2d) 
  res@mpMaxLonF	= max(data@lon2d)
  
; Speed up processing.  
  res@trGridType = "triangularmesh"
  
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")
  
; Create title.
  res@tiMainString = file_name

; Create plot.
  plot = gsn_csm_contour_map_ce(xwks,data,res) 

; Clean up resources.
  delete(plot)
  delete(xwks)
  delete(data)
  delete(res)
  delete(he2_file)
end