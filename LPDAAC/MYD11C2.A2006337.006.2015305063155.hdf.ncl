; 
;  This example code illustrates how to access and visualize
;  LP DAAC MYD11C2 v6 HDF-EOS2 Grid file using NCL. 
;
;  If you have any questions, suggestions, comments  on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage:save this script and run 
; 
; $ncl MYD11C2.A2006337.006.2015305063155.hdf.ncl
;
; Tested under: NCL 6.4.0
; Last updated: 2018-05-07


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

  file_name = "MYD11C2.A2006337.006.2015305063155.hdf"

; To read HDF-EOS2 files, .he2 is appended to the file name argument. 
; For more information, consult section 4.3.2 of [1].
  eos_file=addfile(file_name+".he2", "r")
  
; Uncomment the following line to print all variables and attributes.
;  print(eos_file)

; Read data field.
  data_unscaled = eos_file->LST_Night_CMG_MODIS_8DAY_0_05DEG_CMG_LST 

; FillValue is 0, which will trigger a warning message for NCL during plotting.
; Change it to a different value (i.e., -9999).
  data_valid=where(data_unscaled.eq.data_unscaled@_FillValue, -9999, data_unscaled)
  data_valid@_FillValue = -9999
  
; Apply scale factor.  
  data = (data_valid - data_unscaled@add_offset ) * data_unscaled@scale_factor

; Copy metadata.
  copy_VarMeta(data_unscaled, data)
  data@_FillValue = -9999

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
