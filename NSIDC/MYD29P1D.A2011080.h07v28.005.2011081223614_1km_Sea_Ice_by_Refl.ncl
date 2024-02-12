; This example code illustrates how to access and visualize NSIDC MYD29 1km
; LAMAZ (EASE) Grid file in NCL.

; If you have any questions, suggestions, comments on this example, please use
;  the HDF-EOS Forum (http://hdfeos.org/forums).
;
; If you would like to see an  example of any other NASA HDF/HDF-EOS data
;  product that is not listed in the HDF-EOS Comprehensive Examples page
;  (http://hdfeos.org/zoo), feel free to contact us at
;  eoshelp@hdfgroup.org or post it at the HDF-EOS Forum
; (http://hdfeos.org/forums).

; Example HDF File source:
; ftp://ftp.hdfgroup.uiuc.edu/pub/outgoing/NASAHDF/
;       MYD29P1D.A2011080.h07v28.005.2011081223614.hdf

; Original File Source:
; ftp://n4ftl01u.ecs.nasa.gov/SAN/MOSA/MYD29P1D.005/2011.03.21
;       MYD29P1D.A2011080.h07v28.005.2011081223614.hdf
; File metadata:
; ftp://n4ftl01u.ecs.nasa.gov/SAN/MOSA/MYD29P1D.005/2011.03.21
;       MYD29P1D.A2011080.h07v28.005.2011081223614.hdf.xml
; Browse images:
; ftp://n4ftl01u.ecs.nasa.gov/SAN/MOSA/MYD29P1D.005/2011.03.21
;       BROWSE.MYD29P1D.A2011080.h07v28.005.2011081223614.[1-2].jpg

; load required NCL libraries
load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
; To read HDF-EOS2 files, the file extension ".hdf" can be appended with ".he2"
; in the call to addfile().  The HDF file does not need to be renamed.
; For more information, consult section 4.3.2 of
; http://hdfeos.org/software/ncl.php.

  filename = "MYD29P1D.A2011080.h07v28.005.2011081223614.hdf.he2"
  eos_file=addfile(filename, "r")

; Read data from file
  data =eos_file->Sea_Ice_by_Reflectance_MOD_Grid_Seaice_1km
  dimsize = dimsizes(data)
  nlon = dimsize(0)
  nlat = dimsize(1)

; ncl_filedump of MYD29P1D.A2011080.h07v28.005.2011081223614.hdf.he2  shows
; GridLat_MOD_Grid_Seaice_1km
; corners: (-64.8024, -71.73, -76.4036, -68.0058)
; GridLon_MOD_Grid_Seaice_1km
; corners: (-59.03978834, -45.02008264, -71.5530066577, -78.6761619)
; these values are well-defined, therefore, we can compute geolocation
; internally in NCL

; compute longitude and latitude from the LAMAZ EASE GRID
  lon2d=eos_file->GridLon_MOD_Grid_Seaice_1km
  lat2d=eos_file->GridLat_MOD_Grid_Seaice_1km

  data@lat2d=lat2d
  data@lon2d=lon2d
  data@long_name = data@hdfeos_name

; open workstation
  xwks=gsn_open_wks("pdf", "MYD29P1D.A2011080.h07v28.005.2011081223614.hdf.Sea_Ice_by_Reflectance_1km.ncl")

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
  res@cnLevels = (/1,11,25,37,39,50,200,253,254,255/)

  res@lbLabelPosition = "Center"
  res@lbLabelAlignment = "BoxCenters"
; You can get this list from the field's "Key" attribute using HDFView.
  res@lbLabelStrings = (/"miss","no","night","land","water","ocean","cloud","ice","empty","mask","fill"/)
; Give an explanation about the shortened labels above.
  res@lbTitleString = (/"miss=missing, no=no decision, water=inland water, ice=sea ice, empty=no input tile expected, mask=non-production mask"/)
  res@lbTitlePosition = "Bottom"
; Make the font smaller so that the above long string can fit in one line.
  res@lbTitleFontHeightF = 0.008

; MODIS 1km tile h07v28 is in the Southern Hemisphere -- see reference, below
; LAMBERT Azimuthal Projection with origin at the South pole (-90 lat)
  res@gsnPolar = "SH"

; This EASE Grid tile is defined in the reference, below -- zoom to min lat
  res@mpMaxLatF = max(data@lat2d) ;

; Choose colormap.
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

; Create the title with file name.
  res@tiMainString = filename

; Create plot.
  plot=gsn_csm_contour_map(xwks,data,res)

; Clean up used resources.
  delete(plot)
  delete(xwks)
  delete(data)
  delete(res)
  delete(eos_file)

end

; Reference:
;     MODLAND Developers Home Page
;     http://landdb1.nascom.nasa.gov/developers/index.html
;     http://landdb1.nascom.nasa.gov/developers/grids.html
;     http://landdb1.nascom.nasa.gov/developers/la_tiles/la_grid.html


