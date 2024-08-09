;
;  This example code illustrates how to access and visualize NSIDC MOD29 Grid 
; file in NCL. This file uses LAMAZ projection.
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
;     $ncl MOD29E1D.A2000055.061.2020037150613.hdf.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2024-08-08

begin
; To read HDF-EOS2 files, the file extension ".he2" is added. 
; For more information, consult section 4.3.2 of [1]
  filename = "MOD29E1D.A2000055.061.2020037150613.hdf"  
  eos_file=addfile(filename+".he2", "r") 
;  print(eos_file)

; Read data from file. 
  data =eos_file->Sea_Ice_by_Reflectance_NP_MOD_Grid_Seaice_4km_North
  dimsize = dimsizes(data)
  nlon = dimsize(0)
  nlat = dimsize(1)

  lat = eos_file->GridLat_MOD_Grid_Seaice_4km_North
  lon = eos_file->GridLon_MOD_Grid_Seaice_4km_North
  data@lat2d=lat
  data@lon2d=lon

  xwks=gsn_open_wks("png", filename+".ncl") ; open workstation

  res=True ; plot mods desired

; Set explicit contour levels.
  res@cnLevelSelectionMode = "ExplicitLevels" 
  res@cnLevels = (/1,11,25,37,39,50,200,253,254,255/)
  res@cnFillMode = "RasterFill"
  res@cnFillOn = True
  res@cnLinesOn = False
  res@cnLineLabelsOn = False
  res@cnMissingValFillPattern = 0
  res@cnMissingValFillColor = 0
  
  res@gsnMaximize = True
  res@gsnPolar = "NH" ; Plot northern hemisphere.
  res@gsnSpreadColors = True

  res@lbLabelAlignment = "BoxCenters"
  res@lbLabelPosition = "Center"    
; You can get this list from the field's "Key" attribute using HDFView.
  res@lbLabelStrings = (/"miss","no","night","land","water","ocean","cloud","ice","empty","mask","fill"/)
  
; Give an explanation about the shortened labels above.
  res@lbTitleString = (/"miss=missing, no=no decision, water=inland water, ice=sea ice, empty=no input tile expected, mask=non-production mask"/)
  res@lbTitlePosition = "Bottom"
; Make the font smaller so that the above long string can fit in one line.
  res@lbTitleFontHeightF = 0.008

; This LAMAZ projection lat/lon spans over -90 to 90 and -180 and 180.
; To get a zoomed effect, limit the lat minimum to 30 for NH.
  res@mpMinLatF = 30

; Create the title with file name.
  res@tiMainString = filename 

; Choose colormap.
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

; Create plot.
  plot=gsn_csm_contour_map(xwks,data,res)
end

; References
; [1] http://hdfeos.org/software/ncl.php.