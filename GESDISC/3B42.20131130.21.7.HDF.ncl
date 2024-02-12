;
;   This example code illustrates how to access and visualize GES DISC TRMM
; 3B42 HDF4 Grid file in NCL. 
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
; $ncl 3B42.20131130.21.7.HDF.ncl
; Tested under: NCL 6.4.0
; Last updated: 2017-12-08


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
; Read file. 
  file_name = "3B42.20131130.21.7.HDF"
  hdf4_file=addfile(file_name, "r") 

; Read dataset.
  data=hdf4_file->precipitation
  data@_FillValue=0h
  data!0="lon" ; This file does not contain coordinate variables. 
  data!1="lat" ; To properly display the data, the latitude/longitude must be remapped from its metadata.
  ; See http://www.ncl.ucar.edu/Applications/Scripts/regrid_10.ncl for more information

  dimsize = dimsizes(data)
  numlon = dimsize(0) ; 1440 (from precipitation in hdf file)
  numlat = dimsize(1) ; 400 (from precipitation in hdf file)

; See user guide [1] to calculate latlon.
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
  res@gsnLeftStringFontHeightF = 12 ; make font smaller 
  res@gsnRightStringFontHeightF = 12 ; make font smaller   
  plot=gsn_csm_contour_map(xwks,data(lat|:,lon|:),res)

  delete(plot)
  delete(xwks)
  delete(data)
  delete(res)
  delete(hdf4_file)
end

; References
; [1] https://pmm.nasa.gov/sites/default/files/document_files/3B42_3B43_doc_V7.pdf
