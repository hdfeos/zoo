;
;  This example code illustrates how to access and visualize LaRC CERES SSF NPP
; VIIRS HDF4 file in NCL.
;
;  If you have any questions, suggestions, comments on this example, please use
; the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage:save this script and run 
;
; $ncl CER_SSF1deg-Month_NPP-VIIRS_Edition2A_200203.201909.hdf.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2022-11-07

begin
; Read file.
  file_name = "CER_SSF1deg-Month_NPP-VIIRS_Edition2A_200203.201909.hdf"
  eos_file = addfile(file_name, "r")
  
; List file content.
;  print(eos_file)

  data = eos_file->clr_toa_lw_reg
  
  xwks = gsn_open_wks("png", file_name+".ncl")    ; open workstation
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

  res = True
    
  res@cnFillOn = True
  res@cnFillMode = "RasterFill"
  
  res@cnLinesOn = False
  res@cnLineLabelsOn = False
    
  res@gsnMaximize = True
  res@gsnSpreadColors = True
  
  res@lbLabelAutoStride =  True
  res@lbOrientation = "Vertical"

  res@tiMainString = file_name
  
  plot = gsn_csm_contour_map(xwks,data,res)
end