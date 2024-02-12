;
; 
;  This example code illustrates how to access and visualize GHRC file in NCL.
;
;  If you have any questions, suggestions, comments on this example, please use
; the HDF-EOS Forum (http://hdfeos.org/forums).
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage: save this script and run
;
; $ncl LISOTD_HRAC_V2.3.2015.hdf.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2020-01-07

begin
  file_name = "LISOTD_HRAC_V2.3.2015.hdf"
  hdf_file = addfile(file_name, "r")

  flash = hdf_file->HRAC_COM_FR

  flash@_FillValue=0.0
  flash@_FillValue=-1.0

; Subset data.
  data = flash(:,:,0)
  
; This product uses HDF dimension scale model.
; Thus, lat/lon will be handled automatically by NCL.

  xwks=gsn_open_wks("png", file_name+".ncl") ; open workstation

  res=True                                ; plot mods desired
  res@cnFillOn=True                       ; enable contour fill
  res@cnLinesOn=False                     ; turn off contour lines
  res@gsnSpreadColors=True                ; use the entire color spectrum
  res@cnFillMode="RasterFill"             ; faster
  res@lbLabelAutoStride=True              ; ensure labels do not overlap
  res@lbOrientation = "vertical"          ; vertical labels
  res@cnMissingValFillPattern = 0         ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0             ; white color for missing values

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  res@tiMainString=file_name
  data@long_name = data@long_name + " at Day of year=0"
  plot=gsn_csm_contour_map_ce(xwks,data,res) 
end