;
;  This example code illustrates how to access and visualize OBPG Aqua MODIS
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
; $ncl AQUA_MODIS.20221001_20221031.L3m.MO.RRS.Rrs_412.4km.nc.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2023-11-02

begin
  file_name = "AQUA_MODIS.20221001_20221031.L3m.MO.RRS.Rrs_412.4km.nc"

; Read file. 
  eos_file=addfile(file_name, "r")

; Read the data field.
  data=short2flt(eos_file->Rrs_412)
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

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap
  plot=gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first
end