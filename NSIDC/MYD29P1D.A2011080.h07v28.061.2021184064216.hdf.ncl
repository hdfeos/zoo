;
;  This example code illustrates how to access and visualize NSIDC MOD29P1D
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
; $ncl MYD29P1D.A2011080.h07v28.061.2021184064216.hdf.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2024-08-09

begin
  filename = "MYD29P1D.A2011080.h07v28.061.2021184064216.hdf"
; To read the file as an HDF-EOS2 file, append the file extension ".he2".
; For more information, consult section 4.3.2 of [1]
  eos_file=addfile(filename+".he2", "r")

; Read data from file
  data =eos_file->Sea_Ice_by_Reflectance_MOD_Grid_Seaice_1km
  dimsize = dimsizes(data)
  nlon = dimsize(0)
  nlat = dimsize(1)

; Read lat/lon.
  lon2d=eos_file->GridLon_MOD_Grid_Seaice_1km
  lat2d=eos_file->GridLat_MOD_Grid_Seaice_1km

  data@lat2d=lat2d
  data@lon2d=lon2d

; Open workstation.
  xwks=gsn_open_wks("png", filename+".ncl")

  res=True
  
  res@cnFillMode = "RasterFill"
  res@cnFillOn = True
; Set explicit contour levels.
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels = (/1,11,25,37,39,50,200,253,254,255/)
  res@cnLineLabelsOn = False  
  res@cnLinesOn = False
  res@cnMissingValFillColor = 0
  res@cnMissingValFillPattern = 0

  res@gsnMaximize = True
; MODIS 1km tile h07v28 is in the Southern Hemisphere.  
  res@gsnPolar = "SH"
  res@gsnSpreadColors = True ; use the entire color spectrum
  
  res@lbLabelPosition = "Center"
  res@lbLabelAlignment = "BoxCenters"
; You can get this list from the field's "Key" attribute using HDFView.
  res@lbLabelStrings = (/"miss","no","night","land","water","ocean","cloud","ice","empty","mask","fill"/)
; Give an explanation about the shortened labels above.
  res@lbTitleString = (/"miss=missing, no=no decision, water=inland water, ice=sea ice, empty=no input tile expected, mask=non-production mask"/)
  res@lbTitlePosition = "Bottom"
; Make the font smaller so that the above long string can fit in one line.
  res@lbTitleFontHeightF = 0.008

; Zoom to max lat.
  res@mpMaxLatF = max(data@lat2d) ;

; Create the title with file name.
  res@tiMainString = filename

; Choose colormap.
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

; Create plot.
  plot=gsn_csm_contour_map(xwks,data,res)
end

; References
; [1] http://hdfeos.org/software/ncl.php.