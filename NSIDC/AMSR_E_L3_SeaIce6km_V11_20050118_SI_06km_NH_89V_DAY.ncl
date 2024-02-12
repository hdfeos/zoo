;This example code illustrates how to access and visualize NSIDC_AMSR Grid file in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 2-D grid file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin

  eos_file = addfile("AMSR_E_L3_SeaIce6km_V11_20050118.hdf.he2", "r") ; Read file. 
; read HDF-EOS2 files, .he2 is appended to the argument. 
; For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

  data_raw = eos_file->SI_06km_NH_89V_DAY_NpPolarGrid06km(:,:) ; read data field
; In order to read the SI_06km_NH_89V_DAY data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

; Multiply scale by 0.1 to get Kelvin according to http://nsidc.org/data/docs/daac/ae_si6_6km_tbs.gd.html#2
; Multiply scale by 0.1 to get Kelvin according to http://nsidc.org/data/docs/daac/ae_land3_l3_soil_moisture/data.html
  data = data_raw * 0.1

  data@lon2d = eos_file->GridLon_NpPolarGrid06km; associate longitude and latitude
  data@lat2d = eos_file->GridLat_NpPolarGrid06km

  data@_FillValue = 0h ; Making this double assignment allows the _FillValue of 0 to be properly represented.
  data@_FillValue = -9999h ; 'h' is appended to ensure no type mismatching

  xwks = gsn_open_wks("pdf","AMSR_E_L3_SeaIce6km_V11_20050118_SI_06km_NH_89V_DAY.ncl") ; open workstation

  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn =  False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@lbOrientation = "vertical" ;vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0; white color for missing values

  res@gsnPolar = "NH" ; plot northern hemisphere

  res@mpMinLatF = min(data@lat2d) ; ignore the area outside of the lowest latitude

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
  res@tiMainString = "AMSR_E_L3_SeaIce6km_V11_20050118.hdf" ; create title
  res@gsnLeftString ="Field name: SI_06km_NH_89V_DAY"
  res@gsnRightString ="Units: Kelvin"

  plot = gsn_csm_contour_map(xwks,data,res) ; create plot

  delete(plot) ; cleaning up used resources
  delete(xwks)
  delete(data)
  delete(res)
  delete(eos_file)

end