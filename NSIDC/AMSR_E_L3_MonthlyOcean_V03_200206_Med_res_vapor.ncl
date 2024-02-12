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

  eos_file = addfile("AMSR_E_L3_MonthlyOcean_V03_200206.hdf", "r") ; Read file for the first time. 
  he2_file = addfile("AMSR_E_L3_MonthlyOcean_V03_200206.hdf.he2", "r") ; Read file for the second time to efficiently obtain lat and lon. 

; read data field
  data_raw = eos_file->Med_res_vapor 

; Multiply scale specified in the attribute according to 
; http://nsidc.org/data/docs/daac/ae_ocean_products.gd.html
  data = data_raw * data_raw@Scale

  data@units = data_raw@Unit

; have to use hard codes to obtain -9999.0
  data@_FillValue = -9999.0 * data_raw@Scale

  data!0 = "lat" ; This file does not contain coordinate variables. 
  data!1 = "lon" ; To properly display the data, the latitude/longitude must be remapped from its metadata.

  lat = he2_file->YDim_GlobalGrid
  lon = he2_file->XDim_GlobalGrid

  lat@units = "degrees_north"
  lon@units = "degrees_east"

  data&lat = lat
  data&lon = lon

; open workstation
  xwks = gsn_open_wks("pdf","AMSR_E_L3_MonthlyOcean_V03_200206_Med_res_vapor.ncl") 

  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn = False ; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@lbOrientation = "vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0 ; white color for missing values

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
  res@tiMainString = "AMSR_E_L3_MonthlyOcean_V03_200206.hdf" ; create title
  res@gsnLeftString="Field name: Med_res_vapor"
  res@gsnRightString = "Units: " + data@units

  plot = gsn_csm_contour_map_ce(xwks,data(lat|:,lon|:),res) ; create plot

  delete(plot) ; cleaning up used resources
  delete(xwks)
  delete(data)
  delete(data_raw)
  delete(res)
  delete(he2_file)
  delete(eos_file)

end