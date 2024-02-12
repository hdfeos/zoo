;
;   This example code illustrates how to access and visualize GES DISC GPM
; L1C HDF5 file in NCL. 
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
; $ncl 1C.F19.SSMIS.XCAL2016-V.20160105-S214106-E232259.009078.V05A.HDF5.ncl
;
; Tested under: NCL 6.4.0
; Last updated: 2018-01-22

 
load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is the main program.
begin
  file_name = "1C.F19.SSMIS.XCAL2016-V.20160105-S214106-E232259.009078.V05A.HDF5"

; Read file as an HDF5 file. 
  h5_file = addfile(file_name, "r") 
; print(h5_file)
  g = h5_file=>/S1
  data_raw = g->Tc
  data = data_raw(:,:,0)
  data@long_name = str_squeeze(data_raw@LongName)+" (nchannel1=0)"
  data@lat2d = g->Latitude
  data@lon2d = g->Longitude
  
  wks = gsn_open_wks("png", file_name+".ncl") ; open workstation
  res=True
  res@gsnMaximize=True   ;make plot large
  res@gsnPaperOrientation = "portrait"    ;force portrait orientation
  res@gsnSpreadColors=True    ; use the entire color spectrum
  res@cnFillOn=True   ;enable contour fill
  res@cnLinesOn=False   ;turn off contour line
  res@cnLineLabelsOn =  False    ;turn off contour line labels
  res@cnFillMode="RasterFill"   ;faster
  res@lbLabelAutoStride= True
  res@lbOrientation="vertical" ;vertical labels
  res@trGridType = "TriangularMesh" 
  res@tiMainString = file_name
  res@gsnLeftStringFontHeightF = 10 ; make font smaller 
  res@gsnRightStringFontHeightF = 12 ; make font smaller   
  plot=gsn_csm_contour_map(wks,data,res)

  delete(plot)
  delete(data)
  delete(res)  
  delete(h5_file)
end
