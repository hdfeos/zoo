;
;   This example code illustrates how to access and visualize GES DISC TRMM
; 3A26 v7 HDF4 Grid file in NCL. 
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
; $ncl 3A26.20140101.7.HDF.ncl
; Tested under: NCL 6.4.0
; Last updated: 2017-12-18


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
; Read file. 
  file_name = "3A26.20140101.7.HDF"
  hdf4_file=addfile(file_name, "r") 

; Read dataset.
  data_raw=hdf4_file->rainMeanTH(0,:,:)
  data_raw@_FillValue=-999h
  data=where(data_raw.lt.0, data_raw@_FillValue, data_raw)
  data@units = data_raw@units
  data@long_name = "rainMeanTH at nh3=0"

  ; This file does not contain coordinate variables.
  ; To properly display the data, the latitude/longitude must be remapped from
  ; its metadata.
  data!0="lon" 
  data!1="lat" 


  dimsize = dimsizes(data)
  numlon = dimsize(0) 
  numlat = dimsize(1) 

; See user guide [1] to calculate lat/lon.
  lat=fspan(-49.875,49.875,numlat)
  lon=fspan(-179.875,179.875,numlon)

  lat@units="degrees_north"
  lon@units="degrees_east"

  data&lat=lat
  data&lon=lon

  xwks=gsn_open_wks("png", file_name+".ncl") 
  res = True
  res@gsnMaximize=True   ;make plot large
  res@gsnPaperOrientation = "landscape"    ;force portrait orientation
  res@gsnSpreadColors=True    ; use the entire color spectrum
  res@cnFillOn=True   ;enable contour fill
  res@cnLinesOn=False   ;turn off contour line
  res@cnLineLabelsOn =  False    ;turn off contour line labels
  res@cnFillMode="RasterFill"   ;faster
  res@lbLabelAutoStride= True
  res@lbOrientation="vertical" ;vertical labels
  res@trGridType = "TriangularMesh" 
  res@tiMainString = file_name
  plot=gsn_csm_contour_map(xwks,data(lat|:,lon|:),res)

  delete(plot)
  delete(xwks)
  delete(data)
  delete(res)
  delete(hdf4_file)
end

; References
; [1] https://pps.gsfc.nasa.gov/Documents/filespec.TRMM.V7.pdf
