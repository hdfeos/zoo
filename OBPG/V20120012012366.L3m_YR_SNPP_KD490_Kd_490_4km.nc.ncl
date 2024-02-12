;
;  This example code illustrates how to access and visualize OBPG SNPP VIIRS
; netCDF-4 Grid file in NCL. 
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
; $ncl V20120012012366.L3m_YR_SNPP_KD490_Kd_490_4km.nc.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2020-01-03

begin
  file_name = "V20120012012366.L3m_YR_SNPP_KD490_Kd_490_4km.nc"

; Read file. 
  eos_file=addfile(file_name, "r")

; Read the data field.
  data=short2flt(eos_file->Kd_490)
  lon=eos_file->lon
  lat=eos_file->lat

; Data size is big. Increase work size limitation.
  setvalues NhlGetWorkspaceObjectId() ; make maximum file size larger
  "wsMaximumSize" : 200000000
  end setvalues
  
  xwks=gsn_open_wks("png", file_name+".ncl") ; open workstation

  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@gsnMaximize=True; make plot large
  res@cnLinesOn=False ; turn off contour lines
  res@cnLineLabelsOn=False; turn off contour line labels
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbOrientation="vertical" ; vertical labels
  res@cnMissingValFillPattern=0 ; missing value pattern is set to "SolidFill"
  res@lbLabelAutoStride=True ; ensure no label overlap
  res@tiMainString=file_name
  
; The most values fall under 0.0 ~ 1.0 range. 
  res@cnLevelSelectionMode="ExplicitLevels";
  res@cnLevels=(/0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 7/)

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap
  plot=gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first
end