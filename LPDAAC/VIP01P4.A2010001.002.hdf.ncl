;
;  This example code illustrates how to access and visualize MEaSUREs VIP
; HDF-EOS2 Grid file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.1.0
; Last updated: 2013-1-10


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

  file_name = "VIP01P4.A2010001.002.hdf"

; Open file as HDF4_file to retrieve all attributes.
  hdf4_file=addfile(file_name, "r")

; Open file as HDF-EOS2 file to retrieve geolocation (lat/lon) information.
  eos_file=addfile(file_name+".he2", "r")

; List all available fields and attributes. 
 print(hdf4_file)
 print(eos_file)

; Read data field.
  data_raw = hdf4_file->CMG_0_05_Deg_NDVI

; VIP file stores valid_range as a string of character type instead of 
; two integers of short type.
; Split valid_range string using the comma as a delimeter.
  strs = str_split(data_raw@valid_range, ",")
  
; Convert each string to the same short type as NDVI.
  valid_range0 = stringtoshort(strs(0))
  valid_range1 = stringtoshort(strs(1))

; Filter out invalid values and set them as fill value. 
  data_valid=where(data_raw.gt.valid_range0 .and. data_raw.lt.valid_range1, data_raw, data_raw@_FillValue)

; Divid the value by scale factor to get valid NDVI values.
  data = tofloat(data_valid) / tofloat(data_raw@scale_factor)
  data@long_name = data_raw@long_name
  data@units = data_raw@units

; Associate longitude and latitude.
  data!0="lat"
  data!1="lon"
  data&lat=eos_file->YDim_VIP_CMG_GRID
  data&lon=eos_file->XDim_VIP_CMG_GRID

; Open workstation.
  xwks=gsn_open_wks("pdf", file_name+".ncl") 

; Make maximum filesize larger.
  setvalues NhlGetWorkspaceObjectId() 
  "wsMaximumSize" : 200000000
  end setvalues


  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@cnLinesOn=False ; turn off contour lines
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbLabelAutoStride=True ; ensure labels do not overlap
  res@lbOrientation = "vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0; white color for missing values

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  res@tiMainString = file_name; create title

  plot=gsn_csm_contour_map_ce(xwks,data,res) ; create plot

; Clean up resources.
  delete(plot)
  delete(data)
  delete(data_valid)
  delete(data_raw)
  delete(xwks)
  delete(res)
  delete(eos_file)
  delete(hdf4_file)
end
