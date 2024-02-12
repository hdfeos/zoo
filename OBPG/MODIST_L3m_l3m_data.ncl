;
;  This example code illustrates how to access and visualize OBPG MODIST HDF4 
; file in NCL. 
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
; Last updated: 2012-12-19

;  Please make sure that you have a .hluresfile in your home directory 
; so you don't get any PLCHHQ error messages.
; See http://www.ncl.ucar.edu/Document/Graphics/hlures.shtml for details.
load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"



; We assume that users know how to obtain information such as _FillValue 
; using HDFView.
;
; For information about HDFView, visit 
; http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
; Read file. This is not an HDF-EOS2 file.
; For more information, consult section 4.3.2 of 
; http://hdfeos.org/software/ncl.php.
  file_name = "T20000322000060.L3m_MO_NSST_4.hdf";
  hdf4_file=addfile(file_name, "r")

; List available fields and attributes.
  print(hdf4_file)

; Read the data field
  data_unsigned=hdf4_file->l3m_data
; 'h' is appended to avoid type mismatching.
  data_unsigned@_FillValue=65535h 
; Intercept=-2.0, which is given in the attributes of l3m_data
  theIntercept=data_unsigned@Intercept
; Slope=7.17185E-4, which is given in the attributes of l3m_data
  theSlope=data_unsigned@Slope

; Convert unsigned integer to signed integer for NCL to handle data properly.
  data_signed=where(data_unsigned.lt.inttoshort(0), abs(data_unsigned)+32767, data_unsigned) 

; For the where() function, see 
; http://www.ncl.ucar.edu/Document/Functions/Built-in/where.shtml
;
; NCL treats 65535 as -1

; use short2flt() will get wrong plot
; Slope factor=7.17185E-4, given from the file
; Intercept factor=-2.0, given from the file
;
; For exp() and log(),
; see http://www.ncl.ucar.edu/Document/Functions/list_alpha.shtml
  data=theIntercept+data_signed*theSlope

; This file does not contain geolocation fields. 
  data!0="lat"
  data!1="lon" 

; Set attributes for plot.
  data@long_name = hdf4_file@Parameter
  data@units = hdf4_file@Units

; To properly display the data, the latitude/longitude must be calculated from
;  the file's metadata.
; See http://www.ncl.ucar.edu/Applications/Scripts/regrid_10.ncl for more 
; information
  nLat=hdf4_file@Number_of_Lines ;2160
  nLon=hdf4_file@Number_of_Columns ;4320

  latStep=hdf4_file@Latitude_Step ;0.083333336
  lonStep=hdf4_file@Longitude_Step ;0.083333336

  latStartpoint=hdf4_file@SW_Point_Latitude ;-89.958336
  lonStartpoint=hdf4_file@SW_Point_Longitude ;-179.95833

; For ispan(), see 
; http://www.ncl.ucar.edu/Document/Functions/Built-in/ispan.shtml
  lat=ispan(0,nLat-1,1)*latStep+latStartpoint
  lon=ispan(0,nLon-1,1)*lonStep+lonStartpoint

;lat@Latitude_Units="degrees_North" is wrong.
;lat@units="degrees_North" is also wrong.
  lat@units  = "degrees_north" 

;lon@Longitude_Units="degrees_East" is wrong.
;lon@units="degrees_East" is also wrong.
  lon@units  = "degrees_east"  

; Use north-to-south latitude ordering.
  lat=lat(::-1)

  data&lat=lat
  data&lon=lon

; Open workstation.
  xwks=gsn_open_wks("pdf", file_name) 

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


; You should also make sure you have a .hluresfile in your home directory 
; so you don't get any PLCHHQ error messages.
; see: http://www.ncl.ucar.edu/Document/Graphics/hlures.shtml

  res@tiMainString = file_name


  plot=gsn_csm_contour_map_ce(xwks,data,res) 


  delete(plot) ; cleaning up resources used
  delete(lat)
  delete(lon)
  delete(xwks)
  delete(data)
  delete(res)
  delete(hdf4_file)
end