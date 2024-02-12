;This example code illustrates how to access and visualize NSIDC_MODIS Grid file in NCL. 
;If you have any questions, suggestions, comments on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 2-D grid file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin

  eos_file = addfile("MOD10C1.A2005018.005.2007349093349.hdf.he2", "r") ; Read file. 
; To read HDF-EOS2 files, .he2 is appended to the argument. 
; For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

  data = eos_file->Day_CMG_Snow_Cover_MOD_CMG_Snow_5km(:,:) ; read data field
; In order to read the Day_CMG_Snow_Cover data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.

  xwks = gsn_open_wks("pdf","MOD10C1.A2005018.005.2007349093349_Day_CMG_Snow_Cover.ncl") ; open workstation

  setvalues NhlGetWorkspaceObjectId() ; make maximum filesize larger
  "wsMaximumSize" : 200000000
  end setvalues

  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True ; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn =  False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0; white color for missing values

  res@cnLevelSelectionMode = "ExplicitLevels"   ; set explict contour levels
  res@cnLevels = (/107,111,250,253,254,255/)

  res@lbLabelPosition = "Center"    ; label position
  res@lbLabelAlignment = "BoxCenters"     ; label orientation
  res@lbLabelStrings = (/"0-100","107","111","250","253","254","255"/)

  res@lbTitleString = (/"0-100=percent of snow in cell, 107=lake ice, 111=night, 250=cloud obscured water, 253=data not mapped, 254=water mask, 255=fill"/)
  res@lbTitlePosition = "Bottom"
  res@lbTitleFontHeightF = 0.0125

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
  res@tiMainString = "MOD10C1.A2005018.005.2007349093349.hdf" ; create title
  res@gsnLeftString = "Field name: Day CMG Snow Cover"
  res@gsnRightString = "Untis: none"
  plot = gsn_csm_contour_map_ce(xwks,data,res) ; create plot

  delete(plot) ; cleaning up used resources
  delete(xwks)
  delete(data)
  delete(res)
  delete(eos_file)

end