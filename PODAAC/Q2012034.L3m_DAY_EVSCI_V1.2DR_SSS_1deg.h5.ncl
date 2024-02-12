;  This example code illustrates how to access and visualize PO.DAAC AQUARIUS
; SSS L3 Grid HDF5 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.0.0
; Last updated: 2012-02-27


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
; Read file. This file is simulation data.
  file_name = "Q2012034.L3m_DAY_EVSCI_V1.2DR_SSS_1deg.h5";
  h5_file=addfile(file_name, "r") 

; See what variables are available.
;  print(h5_file)

; Sea Surface Salinity.
  data = h5_file->l3m_data

; Set fill value.
  data@_FillValue = -32767.0

; Filter data based on "Suggested Image Scaling Maximum" and 
; "Suggested Image Scaling Minimum" file attribute values
; as specified in [1].
  data=where(data.gt.(38.0), -32767.0, data)
  data=where(data.lt.(32.0), -32767.0, data)


; Set long_name attribute.
  data@long_name = h5_file@Parameter

; Set units attribute.
  data@units = h5_file@Units

; This file does not contain coordinate variables. 
; To properly display the data, the latitude/longitude must be remapped from 
; its metadata. See [2] for more information.
  data!0="lat"
  data!1="lon" 

  dimsize = dimsizes(data)
  numlat = dimsize(0) ; 180
  numlon = dimsize(1) ; 360

; Define new la/lon.
  lat=new( (/numlat/), float)
  lon=new( (/numlon/), float)

  do i = 0, numlon-1
    lon(i) =  (i + 0.5) - 180.0
  end do

  do j = 0, numlat-1
    lat(j) =  90.0 - (j + 0.5) 
  end do

  lat@units="degrees_north"
  lon@units="degrees_east"

  data&lat=lat
  data&lon=lon

  xwks = gsn_open_wks ("pdf", file_name + ".ncl")    ; open workstation
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

; Create SST plot.
  res = True;
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn = False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@lbOrientation = "vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0; white color for missing values
  res@lbLabelAutoStride = True ; ensure no label overlap
  res@tiMainString = file_name 

  plot = gsn_csm_contour_map_ce(xwks,data,res)  

  delete(res)
  delete(plot)
  delete(xwks)
  delete(data)
  delete(lat)
  delete(lon)
  delete(h5_file)
end

; References
;
; [1] http://podaac.jpl.nasa.gov/sites/default/files/AquariusUserGuideH_V3.0.pdf
; [2] http://www.ncl.ucar.edu/Applications/Scripts/regrid_10.ncl


