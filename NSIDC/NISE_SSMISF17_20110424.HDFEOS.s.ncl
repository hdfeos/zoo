;
; This example code illustrates how to access and visualize NSIDC NISE 25km
; LAMAZ (EASE) Grid file in NCL.  Assistance was provided by Dennis Shea of the
; University Corporation for Atmospheric Research (UCAR) and Wei Huang VETS/CISL
; of the National Center for Atmospheric Research (NCAR), Boulder, CO via the
; ncl-talk mailing list:  http://mailman.ucar.edu/mailman/listinfo/ncl-talk
;
;  If you have any questions, suggestions, comments  on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
;
; Usage:save this script and run 
; 
; $ncl NISE_SSMISF17_20110424.HDFEOS.s.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2019-05-01

begin
; Read the HDF-EOS file.
  filename = "NISE_SSMISF17_20110424.HDFEOS"
  eos_file=addfile(filename+".he2", "r")

; Read data from file.
  bdata=eos_file->Extent_Southern_Hemisphere
;  printVarSummary(bdata)
; Get the dimensions of the data grid.
  dimsize = dimsizes(bdata)
  nlon = dimsize(0)
  nlat = dimsize(1)

; ncl_filedump of NISE_SSMISF17_20110424.HDFEOS.he2 shows:
; GridLat/Lon_Southern_Hemisphere
; corners :      ( 1e+51, 1e+51, 1e+51, 1e+51 )
; this is a bug in the GCTP library
; To properly display the data, the latitude/longitude must be remapped.
; In this example, we used the EOS2 Dumper generate 1D lat and lon ASCII files.
; For information on how to obtain the lat/lon data, see reference [1], below.

  lat=asciiread("lat_NISE_SSMISF17_20110424.Southern_Hemisphere.output",(/nlon,nlat/),"float")
  lon=asciiread("lon_NISE_SSMISF17_20110424.Southern_Hemisphere.output",(/nlon,nlat/),"float")

  bdata@lat2d=lat
  bdata@lon2d=lon
  bdata@long_name = bdata@hdfeos_name
  
; Open the workstation.
  xwks=gsn_open_wks("png", filename+".s.ncl")

  res=True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn = False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0; white color for missing values

; Set explicit contour levels.
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels = (/0,1,21,41,61,81,101,103,104,252,253,255/)

  res@lbLabelPosition = "Center"
  res@lbLabelAlignment = "BoxCenters"
; You can get this list from the field's "Key" attribute using HDFView.
  res@lbLabelStrings = (/"land","1-20%","21-40","41-60","61-80","81-100","sheet","dry","wet"," ","mixed","susp","ocn"/)
  
; Give an explanation about the shortened labels above.
  res@lbAutoManage = "True"  
  res@lbTitleString = (/"land=snow-free land, Percentage Sea Ice, sheet=permanent ice, dry=Dry Snow, wet=Wet Snow, mixed=mixed pixels at coastlines, susp=suspect ice value, ocn=Ocean"/)
  res@lbTitlePosition = "Bottom"
; Make the font smaller so that the above long string can fit in one line.
  res@lbTitleFontHeightF = 0.008

; Plot Southern  hemisphere.
  res@gsnPolar = "SH"

; This LAMAZ projection lat/lon spans over -90 to 90 and -180 and 180.
; To get a zoomed effect, limit the lat max to -30
  res@mpMaxLatF = -30

; Choose colormap.
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

; Create the title with file name.
  res@tiMainString = filename

; Create plot.
  plot=gsn_csm_contour_map(xwks,bdata,res)
end

; References
;
; [1] http://hdfeos.org/zoo/note_non_geographic.php
