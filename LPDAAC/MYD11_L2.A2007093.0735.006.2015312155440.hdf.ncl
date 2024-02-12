;
;   This example code illustrates how to access and visualize LP DAAC MYD11_L2
; v6 HDF-EOS2 Swath file in NCL. 
;
;   If you have any questions, suggestions, comments  on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;   If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage:save this script and run 
; 
; $ncl MYD11_L2.A2007093.0735.006.2015312155440.hdf.ncl
;
; Tested under: NCL 6.4.0
; Last updated: 2018-04-13

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
; Read file.
  file_name="MYD11_L2.A2007093.0735.006.2015312155440.hdf"
  eos_file=addfile(file_name, "r")
  
; List available fields and attributes.
;  print(eos_file)

; Read geolocation file.
  geo_file=addfile("MYD03.A2007093.0735.006.2012073162442.hdf", "r")

; Read data field.
  data_raw=eos_file->LST
  
; Handle valid range. 
; Since FillValue is 0 and valid range is greater than 0, we set invalid range
; values to -9999. The -9999 is chosen because NCL will throw a warning if
; fill value is 0 during plotting [1].

  data_valid=where(data_raw.gt.data_raw@valid_range(0) .and. data_raw.lt.data_raw@valid_range(1), data_raw, -9999)  

; Set fill value.
  data_valid@_FillValue = -9999

; Apply scale factor according to the field attribute.
; "LST : LST data * scale_factor".
  data=data_valid*data_raw@scale_factor
  
; Associate longitude and latitude.
  data@lat2d=geo_file->Latitude 
  data@lon2d=geo_file->Longitude 
  data@units = data_raw@units
  data@long_name = data_raw@long_name
  
; Open workstation
  xwks=gsn_open_wks("png", file_name + ".ncl")

  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@gsnMaximize=True; make plot large
  res@gsnPaperOrientation =	"portrait" ; force portrait orientation
  res@cnLinesOn=False ; turn off contour lines
  res@cnLineLabelsOn       =  False; turn off contour line labels
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbOrientation="vertical" ; vertical labels
  res@lbLabelAutoStride = True ; ensure no label overlap

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap
; Set title.
  res@tiMainString=file_name
  res@mpLimitMode         = "LatLon"
; Set limits of map, based on the min/max of the dataset latitude/longitude.
; This will create a zoomed-in image.
  res@mpMinLatF	= min(data@lat2d) 
  res@mpMaxLatF	= max(data@lat2d)  
  res@mpMinLonF	= min(data@lon2d) 
  res@mpMaxLonF	= max(data@lon2d) 
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

; References
;
; [1] http://www.ncl.ucar.edu/Support/talk_archives/2010/0730.html  