; 
;  This example code illustrates how to access and visualize
;  LP DAAC MCD43C1 HDF-EOS2 Grid file using NCL. 
;
;  If you have any questions, suggestions, comments  on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Tested under: NCL 6.6.2
; Last updated: 2024-11-07

begin

  file_name = "MCD43C1.A2006353.061.2020279143850.hdf"

; To read HDF-EOS2 files, .he2 is appended to the file name argument. 
; For more information, consult section 4.3.2 of [1].
  eos_file=addfile(file_name+".he2", "r")

; Uncomment the following line to print all variables and attributes.
;  print(eos_file)

; Read data field.
  data = eos_file->Percent_Snow_MCD_CMG_BRDF_0_05Deg
  
  xwks = gsn_open_wks("png", file_name + ".ncl") ; open workstation

; These plot needs more memory since the array size is big.
  setvalues NhlGetWorkspaceObjectId() ; make maximum filesize larger
  "wsMaximumSize" : 200000000
  end setvalues

  res = True
  
  res@cnFillMode = "RasterFill"  
  res@cnFillOn = True
  res@cnLinesOn = False
  res@cnMissingValFillColor = 0  
  res@cnMissingValFillPattern = 0
  
  res@gsnLeftStringFontHeightF = 12
  res@gsnMaximize = True
  res@gsnRightStringFontHeightF = 12
  res@gsnSpreadColors = True
  
  res@lbLabelAutoStride = True
  res@lbOrientation = "vertical"

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")
  
  res@tiMainString = file_name ; create title
  plot = gsn_csm_contour_map_ce(xwks, data, res)  
end

; Reference
;
; [1] http://hdfeos.org/software/ncl.php
