; Copyright (C) 2016-2020 by The HDF Group.
;   All rights reserved.
;
; This example code illustrates how to access and visualize NSIDC MOD10CM Grid
; file in NCL.
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
; $ncl MOD10CM.A2000275.061.2020053023258.hdf.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2020-04-10


begin
; Read file.
  file_name = "MOD10CM.A2000275.061.2020053023258.hdf"  
  eos_file = addfile(file_name+".he2", "r")
  
; To read HDF-EOS2 files, .he2 is appended to the argument. 
; For more information, consult section 4.3.2 of [1].

;  print(eos_file)

; Read data field.
  data = eos_file->Snow_Cover_Monthly_CMG_MOD_CMG_Snow_5km(:,:)
  
  xwks = gsn_open_wks("png", file_name+".ncl") ; open workstation
  
; Make maximum filesize larger.
  setvalues NhlGetWorkspaceObjectId() 
  "wsMaximumSize" : 200000000
  end setvalues

  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True ; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn =  False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0; white color for missing values

  res@cnLevelSelectionMode = "ExplicitLevels"   ; set explict contour levels
  res@cnLevels = (/107,111,250,253,254,255/)

  res@lbLabelPosition = "Center"    ; label position
  res@lbLabelAlignment = "BoxCenters"     ; label orientation
  res@lbLabelStrings = (/"0-100","107","111","250","253","254","255"/)

  res@lbTitleString = (/"0-100=percent of snow in cell, 107=lake ice, 111=night, 250=cloud obscured water, 253=data not mapped, 254=water mask, 255=fill"/)
  res@lbTitlePosition = "Bottom"
  res@lbTitleFontHeightF = 0.0125

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
  res@tiMainString = file_name ; create title
  plot = gsn_csm_contour_map_ce(xwks,data,res) ; create plot
end

; References
; [1] http://hdfeos.org/software/ncl.php