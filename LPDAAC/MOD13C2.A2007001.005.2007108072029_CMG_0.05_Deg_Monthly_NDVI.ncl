;  This example code illustrates how to access and visualize LP_DAAC_MOD Grid 
; file in NCL. 
;
;  If you have any questions, suggestions, comments  on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
; 
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; This is an example of a 2-D grid file data field.
begin

; This file is actually an HDF-EOS2 file, but the grid projection parameters 
; are wrong, and this causes segmentation fault when open this file as an 
; HDF-EOS2 file with NCL. We have to open this file as a pure HDF4 file.

  eos_file=addfile("MOD13C2.A2007001.005.2007108072029.hdf", "r") ; Read file. 
  print(eos_file); Print available dataset.

; There is only one vgroup, so the field name is just the original HDF4 SDS 
; object name.
; data_unscaled = \
;   eos_file->CMG_0_05_Deg_Monthly_NDVI_Data_Fields_MOD_Grid_monthly_CMG_VI 
; does not work.
  data_raw = eos_file->CMG_0_05_Deg_Monthly_NDVI; read data field
; Filter out invalid values and set them as fill value.
  data_valid = where(data_raw.gt.data_raw@valid_range(0) .and. data_raw.lt.data_raw@valid_range(1), data_raw, data_raw@_FillValue)
  data_valid@_Fillvalue = data_raw@_FillValue


; We need to divide, not multiply scale to get the correct values.
; Visit the following site and click on "Layers" section.
;    https://lpdaac.usgs.gov/lpdaac/products/modis_products_table/vegetation_indices/monthly_l3_global_0_05deg_cmg/mod13c2 
; Since add_offset is 0, we skip it in the following conversion.
  data = data_valid / data_raw@scale_factor
  data@_FillValue = data_raw@_FillValue  / data_raw@scale_factor
  data@units = data_raw@units

; lat and lon need to be input by the tool, lat: 90, -90, the lon: -180, 180, 
; step: 0.05, lat number: 3600, lon number: 7200

; See http://www.ncl.ucar.edu/Applications/Scripts/regrid_10.ncl for more 
; information
; This file contains coordinate variables that will not properly plot. 
  data!0="lat" 
; To properly display the data, the latitude/longitude must be remapped.
  data!1="lon" 

; Use north-to-south latitude ordering.
  lat = 90 - ispan(0,3600-1,1) * 0.05
  lon = ispan(0,7200-1,1) * 0.05 - 180 

  lat@units  = "degrees_north"
  lon@units  = "degrees_east"

  data&lat=lat
  data&lon=lon


  xwks=gsn_open_wks("pdf","MOD13C2.A2007001.005.2007108072029_CMG_0.05_Deg_Monthly_NDVI") ; open workstation


  setvalues NhlGetWorkspaceObjectId() ; make maximum filesize larger
  "wsMaximumSize" : 200000000
  end setvalues

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


  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
  res@tiMainString = "MOD13C2.A2007001.005.2007108072029.hdf" ; create title
  res@gsnCenterString=data_raw@long_name

  plot=gsn_csm_contour_map_ce(xwks,data,res) ; create plot

  delete(plot) ; cleaning up used resources
  delete(res)
  delete(xwks)
  delete(data)
  delete(data_valid)
  delete(data_raw)

  delete(eos_file)
end
