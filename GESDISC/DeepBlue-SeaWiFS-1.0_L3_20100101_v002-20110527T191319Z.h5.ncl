;  This example code illustrates how to access and visualize GES-DISC MEaSUREs
; SeaWiFS L3 Grid HDF5 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.0.0
; Last updated: 2011-11-14


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
; Read file. 
  file_name = "DeepBlue-SeaWiFS-1.0_L3_20100101_v002-20110527T191319Z.h5";
  h5_file=addfile(file_name, "r") 

; See what variables are available.
;  print(h5_file)

; Latitude.
  lat = h5_file->latitude

; Longitude.
  lon = h5_file->longitude

; Aerosol data.
  data = h5_file->aerosol_optical_thickness_550_ocean

; Set fill value from data using HDFView.
  data@_FillValue = -999.0

; Associate 1D lat/lon with data.
  data!0="lat"
  data!1="lon"
  data&lat=lat
  data&lon=lon

; Create the plot.
  xwks = gsn_open_wks ("pdf", file_name + ".ncl")    ; open workstation
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap
  res = True;
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn = False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@lbOrientation = "vertical" ; vertical labels
  res@lbLabelAutoStride = True ; ensure no label overlap
  res@tiMainString = file_name 
  plot = gsn_csm_contour_map_ce(xwks,data,res)  

; Clean up resources.
  delete(plot)
  delete(res)
  delete(xwks)
  delete(data)
  delete(lon)
  delete(lat)
  delete(h5_file)
end
