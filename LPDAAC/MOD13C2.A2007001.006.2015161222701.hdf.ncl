; 
;  This example code illustrates how to access and visualize
;  LP DAAC MOD13C2 v6 HDF-EOS2 Grid file using NCL. 
;
;  If you have any questions, suggestions, comments  on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Tested under: NCL 6.4.0
; Last updated: 2018-04-13 


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

  file_name = "MOD13C2.A2007001.006.2015161222701.hdf"

; To read HDF-EOS2 files, .he2 is appended to the file name argument. 
; For more information, consult section 4.3.2 of [1].
  eos_file=addfile(file_name+".he2", "r")
  
; Uncomment the following line to print all variables and attributes.
;  print(eos_file)

; Read data field.
  data_unscaled = eos_file->CMG_0_05_Deg_Monthly_NDVI_MOD_Grid_monthly_CMG_VI

; Apply scale factor.
  data = data_unscaled / data_unscaled@scale_factor
  copy_VarMeta(data_unscaled, data)

; Plot data.
  xwks = gsn_open_wks("png", file_name + ".ncl") ; open workstation

; These plot needs more memory since the array size is big.
  setvalues NhlGetWorkspaceObjectId() ; make maximum filesize larger
  "wsMaximumSize" : 200000000
  end setvalues

  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@cnLinesOn=False ; turn off contour lines
  res@gsnMaximize=True ; use entire page
  res@gsnPaperOrientation="Portrait" ; force portrait
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbLabelAutoStride=True ; ensure labels do not overlap
  res@lbOrientation = "vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0; white color for missing values
  res@gsnLeftStringFontHeightF=12 ; make text smaller
  res@gsnRightStringFontHeightF=12


  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")
  res@tiMainString=file_name 
  plot=gsn_csm_contour_map_ce(xwks,data,res)  
  delete(plot)
  delete(res)
  delete(xwks)
  delete(data)
  delete(data_unscaled)
  delete(eos_file)
end

; References
; [1] http://hdfeos.org/software/ncl.php
