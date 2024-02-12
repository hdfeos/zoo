;  This example code illustrates how to access and visualize OBPG_MODISA HDF4 
; file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please use 
; the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.0.0
; Last updated: 2011-10-07

; You should also make sure you have a .hluresfile in your home directory 
; so you don't get any PLCHHQ error messages. See [1] for details.

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"


; This is an example of a 2-D data field.
; It is assumed users know how to obtain information such as _FillValue 
; from HDFView.
; For information about HDFView, visit [2].

begin
  file_name = "A20021612002192.L3m_R32_NSST_4.hdf";
  hdf_file=addfile(file_name, "r") ; Read file. 

; Print all variables and attributes.
;  print(hdf_file)

; This is not an HDF-EOS2 file.
; For more information, consult section 4.3.2 of [3]
  data_unsigned=hdf_file->l3m_data; read data field
  data_unsigned@_FillValue=65535h ; 'h' is appended to avoid type mismatching

  data = tofloat(data_unsigned)

; Apply scale and offset according to Scaling_Equation attribute.
  data = data_unsigned@Slope * data + data_unsigned@Intercept

; This file does not contain geolocation fields. To properly display the data, 
; the latitude/longitude must be remapped from its metadata. See [4] for 
; details.
  data!0="lat" 
  data!1="lon" 

  nLat=hdf_file@Number_of_Lines ;4320
  nLon=hdf_file@Number_of_Columns ;8640

  latStep=hdf_file@Latitude_Step ;0.041666668
  lonStep=hdf_file@Longitude_Step ;0.041666668

  latStartpoint=hdf_file@SW_Point_Latitude ;-89.979164
  lonStartpoint=hdf_file@SW_Point_Longitude ;-179.97917

  lat=ispan(0,nLat-1,1)*latStep+latStartpoint
  lon=ispan(0,nLon-1,1)*lonStep+lonStartpoint
; About ispan, see [5].

  lat@units  = "degrees_north" 
  lon@units  = "degrees_east"  

  lat=lat(::-1) ; use north-to-south latitude ordering

  data&lat=lat
  data&lon=lon

  data@long_name = hdf_file@Parameter
  data@units = hdf_file@Units

  xwks=gsn_open_wks("pdf","A20021612002192.L3m_R32_NSST_4_l3m_data.ncl") ; open workstation 

  setvalues NhlGetWorkspaceObjectId() ; make maximum filesize larger
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

  res@tiMainString =  file_name

  plot=gsn_csm_contour_map_ce(xwks,data,res) 

  delete(plot) ; cleaning up resources used
  delete(res)
  delete(xwks)
  delete(lat)
  delete(lon)
  delete(data)
  delete(data_unsigned)
  delete(hdf_file)
end

; References
;
; [1] http://www.ncl.ucar.edu/Document/Graphics/hlures.shtml
; [2] http://www.hdfgroup.org/hdf-java-html/hdfview/
; [3] http://hdfeos.org/software/ncl.php
; [4] http://www.ncl.ucar.edu/Applications/Scripts/regrid_10.ncl
; [5] http://www.ncl.ucar.edu/Document/Functions/Built-in/ispan.shtml