;  This example code illustrates how to access and visualize PO.DAAC AQUARIUS
; SSS L2 Swath HDF5 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.0.0
; Last updated: 2011-11-10


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
; Read file. 
  file_name = "Q2011280003000.L2_EVSCI_V1.2.h5";
  h5_file=addfile(file_name, "r") 

; See what variables are available.
;  print(h5_file)

; Latitude.
  lat = h5_file->sclat

; Longitude.
  lon = h5_file->sclon

; Sea Surface Salinity.
  data3 = h5_file->SSS

; Salinity can't be bigger than 100.
; Some rows have values such as 5.863178E7.
; Flag them as fill value.
  data3=where(data3.gt.(100.0), -999.0, data3)
  data3@_FillValue = -999.0

; Set 0 as fill value. 
; Commenting out the next two lines can help you to locate satellite path
; when no map limits are used. See 'res@mpLimitMode' code below.
  data3=where(data3.eq.(0.0), -999.0, data3)
  data3@_FillValue = -999.0

; Subset data. There are 3 beams.
  data = data3(:,0)

  xwks = gsn_open_wks ("pdf", file_name + ".ncl")    ; open workstation
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

; Create SST plot.
  res = True;
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn = False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@lbOrientation = "vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0; white color for missing values
  res@lbLabelAutoStride = True ; ensure no label overlap
  res@tiMainString = file_name 
  res@sfYArray = lat
  res@sfXArray = lon

; Set the limits of map. Otherwise, you'll see nothing since satellite path 
; is very thin line on a global map.
; Plotting line graph data using HDFView can help you to find the 
; locations that non-zero value data are concentrated.
  res@mpLimitMode  = "LatLon"
  res@mpMinLatF	= -30
  res@mpMaxLatF	= 20
  res@mpMinLonF	= 40
  res@mpMaxLonF	= 90

  plot = gsn_csm_contour_map_ce(xwks,data,res)  

  delete(res)
  delete(plot)
  delete(xwks)
  delete(data)
  delete(data3)
  delete(lat)
  delete(lon)
  delete(h5_file)
end
