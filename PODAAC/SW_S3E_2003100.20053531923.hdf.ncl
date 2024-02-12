;
;   This example code illustrates how to access and visualize PO.DAAC SeaWinds
; Grid HDF4 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Usage:save this script and run 
; 
; $ncl SW_S3E_2003100.20053531923.hdf.ncl
; 
; Tested under: NCL 6.6.2
; Last updated: 2019-10-14

begin
  file_name = "SW_S3E_2003100.20053531923.hdf"
  hdf_file = addfile(file_name, "r")

  ws = hdf_file->rep_wind_speed

  ws@_FillValue=0h
  ws@_FillValue=-1h

  wss = ws(:,:,0)

; From hdf file, we can find rep_wind_speed is 16-bit unsigned integer
; but if use printVarSummary(hdf_file->rep_wind_speed), then we can find hdf_file->rep_wind_speed is type short,
; so we can still use short2flt() to convert hdf_file->rep_wind_speed using the "scale" and "offset" attributes
; see http://www.ncl.ucar.edu/Document/Functions/Contributed/short2flt.shtml
; short2flt() can handle the following scale and offset:
; scale: "SCALE", "Scale", "_scale", "scale_factor", "Scale_factor", "Slope" , "slope"
; offset: "add_offset", "OFFSET", "Offset", "_offset", "Intercept", "intercept" 
; hdf_file->rep_wind_speed has attributes: scale_factor and add_offset, those attributes can be handled by short2flt()			

  data = short2flt_hdf(wss)


  data!0="lat" ; This file does not contain coordinate variables. 
  data!1="lon" ; To properly display the data, the latitude/longitude must be remapped from its metadata.
; See http://www.ncl.ucar.edu/Applications/Scripts/regrid_10.ncl for more information

  dsizes = dimsizes(data)

  numlat = dsizes(0) ; 720 (from rep_wind_speed in hdf file)
  numlon = dsizes(1) ; 1440 (from rep_wind_speed in hdf file)

; define new latitude
  lat=new( (/numlat/), float)
  lon=new( (/numlon/), float)


; About the calculation of lat and lon,
; see ftp://podaac.jpl.nasa.gov/ocean_wind/seawinds/L3/doc/SWS_L3.pdf

  do i = 0, numlon-1
    lon(i) = (360. / numlon) * (i + 0.5)
  end do

  do j = 0, numlat-1
    lat(j) = (180. / numlat) * (j + 0.5) - 90.
  end do


  lat@units="degrees_north"
  lon@units="degrees_east"

  data&lat = lat
  data&lon = lon

  data@long_name = data@long_name + " at Pass=0"
  xwks = gsn_open_wks("png", file_name+".ncl")

  res=True                                ; plot mods desired
  res@cnFillOn=True                       ; enable contour fill
  res@cnLinesOn=False                     ; turn off contour lines
  res@gsnSpreadColors=True                ; use the entire color spectrum
  res@cnFillMode="RasterFill"             ; faster
  res@lbLabelAutoStride=True              ; ensure labels do not overlap
  res@lbOrientation = "vertical"          ; vertical labels
  res@cnMissingValFillPattern = 0         ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0             ; white color for missing values
  res@mpCenterLonF = 0


; gsn_add_cyclic: Warning: The range of your longitude coordinate array is at least 360.
; You may want to set gsnAddCyclic to False to avoid a warning message from the spline function.
  res@gsnAddCyclic = False  
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap
  res@tiMainString = file_name
  plot=gsn_csm_contour_map_ce(xwks,data,res)
end