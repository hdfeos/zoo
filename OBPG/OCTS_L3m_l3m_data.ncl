;
;  This example code illustrates how to access and visualize OBPG OCTS HDF4 
; L3 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please use
; the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Tested under: NCL 6.0.0
; Last updated: 2012-12-20


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"


begin
; Since the file is not HDF-EOS2, it is not necessary to append .he2
; For more information, consult section 4.3.2 of 
; http://hdfeos.org/software/ncl.php.
  file_name = "O19970011997031.L3m_MO_A520_9.hdf"

; Read file. 
  hdf4_file=addfile(file_name, "r")

; List variables and attributes.
  print(hdf4_file)

; Read the data field.
  data_unsigned=hdf4_file->l3m_data

; You can check the fill value (255) using HDFView.
; Setting the fill value like below doesnt't work in NCL for ubyte type.
; We believe it's a bug in NCL because fill values pass through the type 
; conversion process in the next step.
  data_unsigned@_FillValue = 255B

; Apply scale and offset according to Scaling_Equation attribute:
;  "(Slope*l3m_data) + Intercept = Parameter value";
;  data=theIntercept+data_signed*theSlope
; NCL's byte2flt() function recognizes "Slope" and "Intercept" attributes
; for type conversion.
  data = byte2flt(data_unsigned)

; Set FillValue.
  data@_FillValue = 255 * data_unsigned@Slope + data_unsigned@Intercept
; Another quick way to set fill value is to use the first data point that
; has fill value like below.
;  data@_FillValue = data(0,0)


; This file does not contain geolocation fields. 
; To properly display the data, the latitude/longitude must be computed from 
; its metadata.
; See http://www.ncl.ucar.edu/Applications/Scripts/regrid_10.ncl for more 
; information
  data!0="lat" 
  data!1="lon"


  nLat=hdf4_file@Number_of_Lines ;2160
  nLon=hdf4_file@Number_of_Columns ;4320

  latStep=hdf4_file@Latitude_Step ;0.083333336
  lonStep=hdf4_file@Longitude_Step ;0.083333336

  latStartpoint=hdf4_file@SW_Point_Latitude ;-89.958336
  lonStartpoint=hdf4_file@SW_Point_Longitude ;-179.95833

; See http://www.ncl.ucar.edu/Document/Functions/Built-in/ispan.shtml
  lat=ispan(0,nLat-1,1)*latStep+latStartpoint
  lon=ispan(0,nLon-1,1)*lonStep+lonStartpoint


  lat@units  = "degrees_north" 
  lon@units  = "degrees_east"  

; Use north-to-south latitude ordering
  lat=lat(::-1) 

  data&lat=lat
  data&lon=lon

  data@long_name = hdf4_file@Parameter


; Please note that the hdf4_file@Units is empty because there's no unit.
  data@units = "None"

  xwks=gsn_open_wks("pdf", file_name) ; open workstation 

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


; Please make sure that you have a .hluresfile in your home directory so you 
; don't get any PLCHHQ error messages.
; See http://www.ncl.ucar.edu/Document/Graphics/hlures.shtml
  res@tiMainString =  file_name


  plot=gsn_csm_contour_map_ce(xwks,data,res) 


  delete(plot) ; cleaning up resources used
  delete(lat)
  delete(lon)
  delete(xwks)
  delete(data)
  delete(res)
  delete(hdf4_file)
end