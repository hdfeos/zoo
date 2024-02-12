; This example code illustrates how to access and visualize NSIDC NISE 25km
; LAMAZ (EASE) Grid file in NCL.  Assistance was provided by Dennis Shea of the
; University Corporation for Atmospheric Research (UCAR) and Wei Huang VETS/CISL
; of the National Center for Atmospheric Research (NCAR), Boulder, CO via the
; ncl-talk mailing list:  http://mailman.ucar.edu/mailman/listinfo/ncl-talk

; If you have any questions, suggestions, comments on this example,
; please use the HDF-EOS Forum (http://hdfeos.org/forums).
; If you would like to see an  example of any other NASA HDF/HDF-EOS
; data product that is not listed in the HDF-EOS Comprehensive Examples page
; (http://hdfeos.org/zoo),
; feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Example HDF File source:
; ftp://ftp.hdfgroup.uiuc.edu/pub/outgoing/NASAHDF/
;       NISE_SSMISF17_20110424.HDFEOS
; Original File Source:
; ftp://n4ftl01u.ecs.nasa.gov/SAN/OTHR/NISE.004/2011.04.24/
;       NISE_SSMISF17_20110424.HDFEOS
; File metadata:
; ftp://n4ftl01u.ecs.nasa.gov/SAN/OTHR/NISE.004/2011.04.24/
;       NISE_SSMISF17_20110424.HDFEOS.xml
; Browse images:
; ftp://n4ftl01u.ecs.nasa.gov/SAN/OTHR/NISE.004/2011.04.24/
;       NISE_SSMISF17_20110424.HDFEOS.[1-2].jpg

; load required NCL libraries
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 2-D grid file data field.
; It is assumed users know how to obtain information
; such as _FillValue from HDF View.
; For information about HDFView,
; visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
; Read the HDF-EOS file.
  filename = "NISE_SSMISF17_20110424.HDFEOS.he2"
  eos_file=addfile(filename, "r")
; To read HDF-EOS2 files, .he2 is appended to the argument.
; For more information, consult section 4.3.2 of
; http://hdfeos.org/software/ncl.php

; Read data from file.

; ncl_filedump of NISE_SSMISF17_20110424.HDFEOS.he2 tells us that
; Extent_Northern_Hemisphere has data type (signed)'byte'
; data field name concatenated with grid name
; On 4/8/2011 5:14 PM, Dennis Shea wrote:
; It is *slightly* more efficient to use:
  bdata=eos_file->Extent_Northern_Hemisphere ; read data field(:,:)
; than (previously):
; bdata=eos_file->Extent_Northern_Hemisphere(:,:) ; read data field
; You can use (::7,::7) to subset the data, if necessary

; In order to read the Extent data field from the HDF-EOS2 file,
; the group under which the data field is placed must be appended to the data
; field in NCL.  For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.
  printVarSummary(bdata)
; get the dimensions of the data grid
  dimsize = dimsizes(bdata)
  nlon = dimsize(0)
  nlat = dimsize(1)

; ncl_filedump of NISE_SSMISF17_20110424.HDFEOS.he2 shows:
; GridLat/Lon_Northern_Hemisphere
; corners :      ( 1e+51, 1e+51, 1e+51, 1e+51 )
; this is a bug in the GCTP library
; To properly display the data, the latitude/longitude must be remapped.
; In this example, we used the EOS2 Dumper generate 1D lat and lon ASCII files.
; For information on how to obtain the lat/lon data, see reference [1], below.

  lat=asciiread("lat_NISE_SSMISF17_20110424.Northern_Hemisphere.output",(/nlon,nlat/),"float")
  lon=asciiread("lon_NISE_SSMISF17_20110424.Northern_Hemisphere.output",(/nlon,nlat/),"float")

  bdata@lat2d=lat
  bdata@lon2d=lon
  bdata@long_name = bdata@hdfeos_name

; open the workstation viewer
  xwks=gsn_open_wks("pdf", "NISE_SSMISF17_20110424.HDFEOS.Extent_Northern_Hemisphere.ncl")

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
  res@lbTitleString = (/"land=snow-free land, Percentage Sea Ice, sheet=permanent ice, dry=Dry Snow, wet=Wet Snow, mixed=mixed pixels at coastlines, susp=suspect ice value, ocn=Ocean"/)
  res@lbTitlePosition = "Bottom"
; Make the font smaller so that the above long string can fit in one line.
  res@lbTitleFontHeightF = 0.008

; Plot Northern  hemisphere.
  res@gsnPolar = "NH"

; This LAMAZ projection lat/lon spans over -90 to 90 and -180 and 180.
; To get a zoomed effect, limit the lat max to -30
  res@mpMinLatF = 30

; Choose colormap.
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

; Create the title with file name.
  res@tiMainString = filename

; Create plot.
  plot=gsn_csm_contour_map(xwks,bdata,res)

; Clean up used resources.
  delete(plot)
  delete(xwks)
  delete(bdata)
  delete(res)
  delete(eos_file)

end

; References
;
; [1] http://hdfeos.org/zoo/note_non_geographic.php
