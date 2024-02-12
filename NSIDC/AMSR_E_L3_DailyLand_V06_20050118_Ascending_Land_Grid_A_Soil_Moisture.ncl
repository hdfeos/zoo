load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 2-D grid file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin

  eos_file=addfile("AMSR_E_L3_DailyLand_V06_20050118.hdf.he2", "r") ; Read file. 
; To read HDF-EOS2 files, .he2 is appended to the argument. 
; For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

  data=eos_file->A_Soil_Moisture_Ascending_Land_Grid(:,:) ; read data field
; In order to read the A_Soil_Moisture data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

  data@lon2d=eos_file->GridLon_Ascending_Land_Grid; associate longitude and latitude
  data@lat2d=eos_file->GridLat_Ascending_Land_Grid

  xwks=gsn_open_wks("pdf","AMSR_E_L3_DailyLand_V06_20050118_Ascending_Land_Grid_A_Soil_Moisture.ncl") ; open workstation

  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@gsnMaximize=True; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn =  False; turn off contour line labels
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbOrientation="vertical" ;vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0; white color for missing values

  res@mpProjection = "CylindricalEqualArea" ; change map projection 

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
  res@tiMainString = "AMSR_E_L3_DailyLand_V06_20050118.hdf" ; create title
  res@gsnCenterString="A_Soil_Moisture"

  plot=gsn_csm_contour_map(xwks,data,res) ; create plot

  delete(plot) ; cleaning up used resources
  delete(xwks)
  delete(data)
  delete(res)
  delete(eos_file)

end