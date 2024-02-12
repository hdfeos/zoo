; 
;  This example code illustrates how to access and visualize LaRC MISR
; AM1 CGAL HDF-EOS2 Grid file in NCL. 
;
;  If you have any questions, suggestions, comments  on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; $ncl MISR_AM1_CGAL_2017_F06_0024.hdf.ncl
;
; Tested under: NCL 6.4.0
; Last updated: 2018-08-10

begin
  file_name = "MISR_AM1_CGAL_2017_F06_0024.hdf"
  eos_file=addfile(file_name+".he2", "r") ; Read file. 

; Read specific subset of data field.
  data=eos_file->Local_albedo_average___1_deg_AlbedoAverage_1_degree(:,:,3)
  data@long_name = "Local albedo average - 1 deg at Band=3"

; Albedo doesn't have a unit according to the specification [1].  
  data@units = "No Units"

  xwks=gsn_open_wks("png", file_name+".ncl")
  
  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@gsnMaximize=True; make plot large
  res@gsnPaperOrientation =	"portrait" ; force portrait orientation
  res@cnLinesOn=False ; turn off contour lines
  res@cnLineLabelsOn       =  False; turn off contour line labels
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbOrientation="vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0; white color for missing values
  res@lbLabelAutoStride = True ; ensure no label overlap

  res@cnLevelSelectionMode="ManualLevels" ; preset range defined to ensure uniform color legend across all levels
  res@cnLevelSpacingF=.05 ; set interval
  res@cnMinLevelValF=0 ; set min and max values
  res@cnMaxLevelValF=1 ;

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap


  res@tiMainString=file_name
  plot=gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first  
end

; References
;
; [1] https://asdc.larc.nasa.gov/documents/misr/DPS_v50_RevS.pdf
