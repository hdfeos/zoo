;
;  This example code illustrates how to access and visualize LaRC CERES SSF
; NPP VIIRS HDF4 file in NCL.
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
; $ncl CER_SSF1deg-Hour_NPP-VIIRS_Edition2A_200203.20190930.hdf.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2022-10-25

begin
; Read file.
  file_name = "CER_SSF1deg-Hour_NPP-VIIRS_Edition2A_200203.20190930.hdf"
  eos_file = addfile(file_name, "r")
  
; List file content.
;  print(eos_file)

; Select GMT hour index [0-1].
  data = eos_file->clr_toa_lw(0,:,:)
  idx = eos_file->gmt_hour_index(0) 
  data@long_name = data@long_name + " at " + idx@long_name + " = " + idx
  
  xwks   = gsn_open_wks("png", file_name+".ncl")    ; open workstation
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

  res=True
  res@gsnMaximize=True   ;make plot large
  res@gsnPaperOrientation = "portrait"    ;force portrait orientation
  res@gsnSpreadColors=True    ; use the entire color spectrum
  res@cnFillOn=True   ;enable contour fill
  res@cnLinesOn=False   ;turn off contour line
  res@cnLineLabelsOn =  False    ;turn off contour line labels
  res@cnFillMode="RasterFill"   ;faster
  res@lbLabelAutoStride= True
  res@lbOrientation        = "Vertical"

  res@tiMainString = file_name
  plot=gsn_csm_contour_map(xwks,data,res)
end