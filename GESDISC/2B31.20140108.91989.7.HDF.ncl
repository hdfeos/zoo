;
;   This example code illustrates how to access and visualize GES DISC TRMM
; 2B31 HDF4 Swath  file in NCL. 
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
; $ncl 2B31.20140108.91989.7.HDF.ncl
; Tested under: NCL 6.4.0
; Last updated: 2017-12-07

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
; Read file.
  file_name = "2B31.20140108.91989.7.HDF"
  hdf4_file=addfile(file_name, "r") ; Read file.
  
; Read dataset.
  data=hdf4_file->rrSurf

; Handle fill value according to [1].  
  data@_FillValue = -9999.9
  data@lon2d=hdf4_file->Longitude
  data@lat2d=hdf4_file->Latitude

  wks=gsn_open_wks("png", file_name+".ncl") ; open workstation
  res=True
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
  plot=gsn_csm_contour_map(wks,data,res)

  delete(plot) 
  delete(data)
  delete(res)
  delete(hdf4_file)
end

; Reference
; [1] https://disc2.gesdisc.eosdis.nasa.gov/data/TRMM_L2/TRMM_2B31/doc/README.TRMM_V7.pdf