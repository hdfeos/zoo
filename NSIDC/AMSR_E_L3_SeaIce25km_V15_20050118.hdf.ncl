;
;  This example code illustrates how to access and visualize AMSR-E Sea Ice
; 25km L3 HDF-EOS2 Grid file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage:
;
;   $ncl AMSR_E_L3_SeaIce25km_V15_20050118.hdf.ncl
;
; Tested under: NCL 6.5.0
; Last updated: 2018-12-14

begin
  file_name = "AMSR_E_L3_SeaIce25km_V15_20050118.hdf"
; Open file.
; To read the file as HDF-EOS2 file, .he2 is appended to the argument. 
; For more information, consult section 4.3.2 of
; http://hdfeos.org/software/ncl.php.
  eos_file=addfile(file_name+".he2", "r") 

  data_raw=eos_file->SI_25km_NH_06V_ASC_NpPolarGrid25km(:,:)
;  printVarSummary(data_raw)
  
; Multiply by 0.1 to get Kelvin
; https://nsidc.org/data/amsre/ae_si25_25km_seaice
  data=data_raw * 0.1
; Associate longitude and latitude.
  data@lon2d=eos_file->GridLon_NpPolarGrid25km
  data@lat2d=eos_file->GridLat_NpPolarGrid25km
; Making this double assignment allows the _FillValue of 0 to be properly
; represented.  
  data@_FillValue=0h
; 'h' is appended to ensure no type mismatching  
  data@_FillValue=-9999h

  data@long_name = data_raw@hdfeos_name
  data@units = "K"
  xwks=gsn_open_wks("png", file_name+".ncl") ; open workstation

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

  res@gsnPolar = "NH" ; plot northern hemisphere

  res@mpMinLatF = min(data@lat2d) ; ignore the area outside of the lowest latitude

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
  res@tiMainString = "AMSR_E_L3_SeaIce25km_V11_20050118.hdf" ; create title

;  res@gsnLeftString ="Field name: SI_25km_NH_06V_ASC"
;  res@gsnRightString ="Units: Kelvin"
  plot=gsn_csm_contour_map(xwks,data,res) ; create plot
end