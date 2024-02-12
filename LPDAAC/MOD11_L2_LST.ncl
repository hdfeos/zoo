;   This example code illustrates how to access and visualize LP_DAAC_MOD swath
; file in NCL. 
;
;   If you have any questions, suggestions, comments  on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;   If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 2-D swath file data field.
begin
; Read dataset file.
  eos_file=addfile("MOD11_L2.A2007278.0350.005.2007280073443.hdf", "r")
; List available fields and attributes.
  print(eos_file)

; Read geolocation file.
  geo_file=addfile("MOD03.A2007278.0350.005.2009162161456.hdf", "r") 
; Because dimension maps are used in the eos_file, we must use geolocation 
; values that are stored in a secondary file.

  data_raw=eos_file->LST; read data field
; Filter out invalid values and set them as fill value.
  data_valid=where(data_raw.gt.data_raw@valid_range(0) .and. data_raw.lt.data_raw@valid_range(1), data_raw, data_raw@_FillValue)
  data_valid@_FillValue = data_raw@_FillValue

; Apply scale factor according to the field attribute 
; "LST : LST data * scale_factor".
  data=data_valid*data_raw@scale_factor

; Associate longitude and latitude
  data@lat2d=geo_file->Latitude 
  data@lon2d=geo_file->Longitude 
  data@unit = data_raw@units

; NCL contour doesn't allow 0.0 for _FillValue. 
; See http://www.ncl.ucar.edu/Support/talk_archives/2010/0730.html
; Thus, we cannot use the attribute value directly like below because it is 0.
;  data@_FillValue = data_raw@_FillValue

; Instead, let's use default fill values for double type.
; See http://www.ncl.ucar.edu/Document/Manuals/Ref_Manual/NclVariables.shtml
; From NCL 6.0.0, it should be 9.969209968386869e+36
  data@_FillValue=-9999.0

; Open workstation
  xwks=gsn_open_wks("pdf","MOD11_L2.A2007278.0350.005.2007280073443_LST")

  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@gsnMaximize=True; make plot large
  res@gsnPaperOrientation =	"portrait" ; force portrait orientation
  res@cnLinesOn=False ; turn off contour lines
  res@cnLineLabelsOn       =  False; turn off contour line labels
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbOrientation="vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0; white color for missing values
  res@lbLabelAutoStride = True ; ensure no label overlap

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap
; Create title.
  res@tiMainString="MOD11_L2.A2007278.0350.005.2007280073443.hdf"
  res@gsnCenterString=data_raw@long_name ; create center text
  plot=gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first
  delete(res@tiMainString) ; delete title for subsequent plots


  res@mpLimitMode         = "LatLon"
; Set limits of map, based on the min/max of the dataset latitude/longitude.
; This will create a zoomed image.
  res@mpMinLatF	= min(data@lat2d) 
  res@mpMaxLatF	= max(data@lat2d)  
  res@mpMinLonF	= min(data@lon2d) 
  res@mpMaxLonF	= max(data@lon2d) 
; Create center text.
  res@gsnCenterString= data_raw@long_name
  plot=gsn_csm_contour_map_ce(xwks,data,res)  
; Clean up resources used.
  delete(plot) 
  delete(xwks)
  delete(data)
  delete(data_valid)
  delete(data_raw)
  delete(res)
  delete(eos_file)
end
