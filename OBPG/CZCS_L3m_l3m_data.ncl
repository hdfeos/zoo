;
;  This example code illustrates how to access and visualize OBPG CZCS HDF4 
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
  file_name = "C19860011986008.L3m_8D_CHLO_4.hdf"

; Read file. 
  hdf4_file=addfile(file_name, "r") 

; Read the data field.
  data_unsigned=hdf4_file->l3m_data

; 'h' is appended to avoid type mismatching.
  data_unsigned@_FillValue=65535h

; Intercept=-2.0, which is given in the attributes of l3m_data
  theIntercept=data_unsigned@Intercept 

; Slope=5.8137757E-5, which is given in the attributes of l3m_data
  theSlope=data_unsigned@Slope

; Convert unsigned integer to signed integer.
; NCL treats 65535 as -1.
  data_signed=where(data_unsigned.lt.inttoshort(0), abs(data_unsigned)+32767, data_unsigned)

; The following scale offset rule is based on the Scaling_Equation attribute of
; the dataset.
  data=exp( (theIntercept+data_signed*(theSlope)) * log(10) )
  data=where((data.lt.(0.01)).or.(data.gt.(1)), data_unsigned@_FillValue, data)

; This file does not contain geolocation fields. 
; To properly display the data, the latitude/longitude must be computed from 
; its metadata.
; See http://www.ncl.ucar.edu/Applications/Scripts/regrid_10.ncl for more 
; information
  data!1="lon" 
  data!0="lat" 
  nLat=hdf4_file@Number_of_Lines ;4320
  nLon=hdf4_file@Number_of_Columns ;8640

  latStep=hdf4_file@Latitude_Step ;0.041666668
  lonStep=hdf4_file@Longitude_Step ;0.041666668

  latStartpoint=hdf4_file@SW_Point_Latitude ;-89.979164
  lonStartpoint=hdf4_file@SW_Point_Longitude ;-179.97917

; See http://www.ncl.ucar.edu/Document/Functions/Built-in/ispan.shtml
  lat=ispan(0,nLat-1,1)*latStep+latStartpoint
  lon=ispan(0,nLon-1,1)*lonStep+lonStartpoint

; Set attributes for plot labels.
  lat@units  = "degrees_north" 
  lon@units  = "degrees_east"  

; Use north-to-south latitude ordering.
  lat=lat(::-1) 

  data&lat=lat
  data&lon=lon
  data@long_name = hdf4_file@Parameter
  data@units = hdf4_file@Units

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

; Please make sure that you have a .hluresfile in your home directory 
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

; Reference
;
; [1] http://oceancolor.gsfc.nasa.gov/ANALYSIS/PROCTEST/cr01_sr051/deep_chlor_a_images.html
