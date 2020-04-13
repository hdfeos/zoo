; Copyright (C) 2011-2020 by The HDF Group.
;   All rights reserved.
;
;  This example code illustrates how to access and visualize NSIDC MOD29P1N
; HDF-EOS2 Grid file in NCL. This file uses LAMAZ projection.
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
; $ncl MOD29P1N.A2001065.h15v10.061.2020058175438.hdf.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2020-04-13

begin
  filename = "MOD29P1N.A2001065.h15v10.061.2020058175438.hdf"
; To read the file as an HDF-EOS2 file, append the file extension ".he2".
; For more information, consult section 4.3.2 of [1]
  eos_file = addfile(filename+".he2", "r")
  print(eos_file)
; Read data from file.
  print(min(eos_file->Ice_Surface_Temperature_MOD_Grid_Seaice_1km))
  print(max(eos_file->Ice_Surface_Temperature_MOD_Grid_Seaice_1km))  
  data = short2flt(eos_file->Ice_Surface_Temperature_MOD_Grid_Seaice_1km)
  dimsize = dimsizes(data)
  nlon = dimsize(0)
  nlat = dimsize(1)

; Set longitude and latitude for the LAMAZ EASE GRID.
  lon2d=eos_file->GridLon_MOD_Grid_Seaice_1km
  lat2d=eos_file->GridLat_MOD_Grid_Seaice_1km

  data@lat2d=lat2d
  data@lon2d=lon2d

; Save as PNG image.
  xwks=gsn_open_wks("png", filename+".ncl")

  res=True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True; make plot large
  ; res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn = False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0; white color for missing values

; Set explicit contour levels.
  res@cnLevelSelectionMode = "ExplicitLevels"
;  res@cnLevels = (/1,11,25,37,39,50,200,253,254,255/)
  res@cnLevels = (/1,11,25,37,39,50,243,273,655.35/)

  res@lbLabelPosition = "Center"
  res@lbLabelAlignment = "BoxCenters"
; You can get this list from the field's "Key" attribute using HDFView.
;  res@lbLabelStrings = (/"miss","no","night","land","water","ocean","cloud","ice","empty","mask","fill"/)
  res@lbLabelStrings = (/"miss","no","night","land","water","ocean","cloud","243","273","fill"/)
; Give an explanation about the shortened labels above.
;  res@lbTitleString = (/"miss=missing, no=no decision, water=inland water, ice=sea ice, empty=no input tile expected, mask=non-production mask"/)
;  res@lbTitlePosition = "Bottom"
; Make the font smaller so that the above long string can fit in one line.
  res@lbTitleFontHeightF = 0.008

; MODIS 1km tile h14v30 is in the Northern Hemisphere -- see reference, below
; LAMBERT Azimuthal Projection with origin at the North pole (+90 lat)
;  res@gsnPolar = "SH"

; This EASE Grid tile is defined in the reference, below -- zoom to min lat
;  res@mpMinLatF	= min(data@lat2d) ; 

; Choose colormap.
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

; Create the title with file name.
  res@tiMainString = filename

; Create plot.
  plot=gsn_csm_contour_map(xwks,data,res)
end

; References
; [1] http://hdfeos.org/software/ncl.php.
