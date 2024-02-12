;
;  This example code illustrates how to access and visualize NSIDC AMSR-E V15 HDF-EOS2
; Grid file in NCL. 
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
; $ncl AMSR_E_L3_SeaIce12km_V15_20020603.hdf.s.ncl
; Tested under: NCL 6.3.0
; Last updated: 2016-02-26


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 2-D grid file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
  file_name = "AMSR_E_L3_SeaIce12km_V15_20020603.hdf"
  
; To read the file as an HDF-EOS2 file, .he2 suffix is appended to the argument.
; For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.
  eos_file=addfile(file_name+".he2", "r") ; Read file.

; Dump the content of file.
; print(eos_file)


  data=eos_file->SI_12km_SH_ICECON_DAY_SpPolarGrid12km(:,:) ; read data field


; Associate longitude and latitude.
  data@lon2d=eos_file->GridLon_SpPolarGrid12km
  data@lat2d=eos_file->GridLat_SpPolarGrid12km

; Assign out of range values (e.g.,  110, 120) as fill values:
; http://nsidc.org/data/docs/daac/ae_si12_12km_seaice/data.html
  data@_FillValue=120h ; 'h' is appended to ensure no type mismatching.
  data@_FillValue=110h

  data@long_name= data@hdfeos_name
  data@units="Percent"
  xwks = gsn_open_wks("png", file_name+".s.ncl") ; open workstation

  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@gsnMaximize=True; make plot large
  res@gsnPaperOrientation =	"portrait" ; force portrait orientation
  res@cnLinesOn=False ; turn off contour lines
  res@cnLineLabelsOn       =  False; turn off contour line labels
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbOrientation="vertical" ;vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0; white color for missing values

  res@gsnPolar = "SH" ; plot southern hemisphere

  res@mpMaxLatF = max(data@lat2d) ; ignore the area outside of the highest latitude

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
  res@tiMainString = file_name ; create title


  plot=gsn_csm_contour_map(xwks,data,res) ; create plot

  delete(plot) ; cleaning up used resources
  delete(xwks)
  delete(data)
  delete(res)
  delete(eos_file)
end