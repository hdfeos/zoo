;
;   This example code illustrates how to access and visualize LAADS VIIRS Swath
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
  file_name = "NPP_VSTIP_L2.A2012002.2340.P1_03001.2012022162425.hdf";
  eos_file=addfile(file_name, "r")

; List available fields and attributes.
  print(eos_file)

; Read data field.
  data_raw =eos_file->SurfaceTemperature(0:6143:10, 0:6399:10)
; This is an arbitrary fill value.
  data_raw@_FillValue = -9999.000000
; We assume that any valid data is greater than 0.
; HDFView shows that most of values are -999.8 or -999.9 and we assume that
; they are fill values.
  data=where(data_raw.gt.0, data_raw, data_raw@_FillValue)
  data@_FillValue = data_raw@_FillValue

; Select every 10 point. Otherwise, memory allocation error occurs.
  data@lat2d=eos_file->Latitude(0:6143:10, 0:6399:10)
  data@lon2d=eos_file->Longitude(0:6143:10, 0:6399:10)
;  data@lat2d=eos_file->Latitude
;  data@lon2d=eos_file->Longitude
  data@long_name = data_raw@hdf_name
  printVarSummary(data)

; Open workstation
  xwks=gsn_open_wks("pdf",file_name)

; These plot needs more memory since the array size is big.
  setvalues NhlGetWorkspaceObjectId() ; make maximum filesize larger
  "wsMaximumSize" : 300000000
  end setvalues

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
; Without the following statement, it will take too long.
;  res@trGridType = "TriangularMesh" 


  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap
; Create title.
  res@tiMainString=file_name
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
  plot=gsn_csm_contour_map(xwks,data,res)  
; Clean up resources used.
  delete(plot) 
  delete(xwks)
  delete(data)
  delete(res)
  delete(eos_file)
end
