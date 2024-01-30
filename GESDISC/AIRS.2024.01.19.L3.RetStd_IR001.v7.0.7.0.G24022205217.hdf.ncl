;
;   This example code illustrates how to access and visualize GES DISC AIRS v7
; Grid HDF-EOS2 file in NCL. 
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
; $ncl AIRS.2024.01.19.L3.RetStd_IR001.v7.0.7.0.G24022205217.hdf.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2024-01-30

begin

  file_name = "AIRS.2024.01.19.L3.RetStd_IR001.v7.0.7.0.G24022205217.hdf"

; To read HDF-EOS2 files, .he2 is appended to the argument.
; For more information, consult section 4.3.2 of [2].
  eos_file=addfile(file_name+".he2", "r") ; Read file.

; print(eos_file)

; Read specific subset of data field.
  data=eos_file->Temperature_A_ascending(0, :,:)
  data@unit = "K"
  d = tostring(eos_file@Year_location) + "-"
  d = d + tostring(eos_file@Month_location) + "-"
  d = d + tostring(eos_file@Day_location)
  data@long_name = data@hdfeos_name + " at StdPrsLvls=0" + " on " + d
  
  xwks=gsn_open_wks("png", file_name+".ncl")
  res=True 
  res@cnFillOn=True
  res@gsnMaximize=True
  res@gsnPaperOrientation="landscape"
  res@cnLinesOn=False
  res@cnLineLabelsOn=False
  res@gsnSpreadColors=True
  res@cnFillMode="RasterFill"
  res@lbOrientation="vertical"
  res@cnMissingValFillPattern=0
  res@cnMissingValFillColor=0

  gsn_define_colormap(xwks,"amwg")
  res@tiMainString=file_name
  plot=gsn_csm_contour_map_ce(xwks,data,res)
end

