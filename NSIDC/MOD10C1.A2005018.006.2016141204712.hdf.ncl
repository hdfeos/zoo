;
;  This example code illustrates how to access and visualize NSIDC MOD10C1
; L3 HDF-EOS2 Grid file in NCL.
;
;  If you have any questions, suggestions, comments on this example,
; please use the HDF-EOS Forum (http://hdfeos.org/forums).
;
;   If you would like to see an  example of any other NASA HDF/HDF-EOS
; data product that is not listed in the HDF-EOS Comprehensive Examples page
; (http://hdfeos.org/zoo), ;feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
;
; Usage:save this script and run 
; 
; $ncl MOD10C1.A2005018.006.2016141204712.hdf.ncl
;
; Tested under: NCL 6.5.0
; Last updated: 2019-02-22

begin
  file_name = "MOD10C1.A2005018.006.2016141204712.hdf"

; To read HDF-EOS2 files, .he2 is appended to the argument. 
; For more information, consult section 4.3.2 of
;  http://hdfeos.org/software/ncl.php.
  
  eos_file = addfile(file_name+".he2", "r") 
  data = eos_file->Day_CMG_Snow_Cover_MOD_CMG_Snow_5km(:,:)
  delete(data@_FillValue)

  xwks = gsn_open_wks("png", file_name+".ncl") 

 ; Make maximum filesize larger.
  setvalues NhlGetWorkspaceObjectId()
  "wsMaximumSize" : 200000000
  end setvalues

  res = True
  res@cnFillOn = True
  res@gsnMaximize = True
  res@gsnPaperOrientation = "portrait"
  res@cnLinesOn = False
  res@cnLineLabelsOn =  False
  res@gsnSpreadColors = True
  res@cnFillMode = "RasterFill"
  res@cnMissingValFillPattern = 0
  res@cnMissingValFillColor = 0

  ; Set explict contour levels.
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels = (/1,100,107,111,237,239,250,253,255/)

  res@lbLabelPosition = "Center"
  res@lbLabelAlignment = "BoxCenters"
  res@lbLabelStrings = (/"0","1-99","100","107","111","237","239","250","253","255"/)

  res@lbTitleString = (/"0=no snow, 1-99=percent of snow in cell, 100=snow, 107=lake ice, 111=night, 237=inland water, 239=ocean, 250=cloud obscured water, 253=data not mapped, 255=fill"/)
  res@lbTitlePosition = "Bottom"
  res@lbTitleFontHeightF = 0.0125

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")
  res@tiMainString = file_name
;  res@gsnLeftString = "Field name: Day CMG Snow Cover"
;  res@gsnRightString = "Untis: none"
  plot = gsn_csm_contour_map_ce(xwks,data,res) ; create plot
end