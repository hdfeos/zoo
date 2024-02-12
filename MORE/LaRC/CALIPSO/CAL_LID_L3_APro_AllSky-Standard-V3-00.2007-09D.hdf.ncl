; 
;  This example code illustrates how to access and visualize LaRC CALIPSO
; LIDAR L3 Aerosol Profile HDF4 file in NCL. 
;
;  If you have any questions, suggestions, comments  on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; $ncl CAL_LID_L3_APro_AllSky-Standard-V3-00.2007-09D.hdf.ncl
;
; Tested under: NCL 6.5.0
; Last updated: 2019-03-09

begin
  file_name = "CAL_LID_L3_APro_AllSky-Standard-V3-00.2007-09D.hdf"
  
; Read file. 
  hdf_file = addfile(file_name, "r") 

; The following line prints all variables and attributes.
;  print(hdf_file)

  lat = hdf_file->Latitude_Midpoint(0,:)
;  print(lat)
  lon = hdf_file->Longitude_Midpoint(0,:)
;  print(lon)
  alt = hdf_file->Altitude_Midpoint(0,10)
  
; Subset aerosol type at Altutide = 10.
; The last dimension has 6 aerosol type choices.
  data = hdf_file->Aerosol_Type(:,:,10,0)
  data@long_name = data@hdf_name + " at height = "+alt + " and type index=0"
;  printVarSummary(data)
  data!0 = "lat"
  data!1 = "lon"

  lat@units="degrees_north"
  lon@units="degrees_east"

  data&lat=lat
  data&lon=lon

  xwks=gsn_open_wks("png", file_name+".ncl") ; open workstation 

  setvalues NhlGetWorkspaceObjectId() ; make maximum filesize larger
  "wsMaximumSize" : 200000000
  end setvalues

  res=True ; plot mods desired


  res@cnFillOn=True ; enable contour fill
  res@gsnMaximize=True; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn=False ; turn off contour lines
  res@cnLineLabelsOn =  False; turn off contour line labels
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbOrientation = "vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0; white color for missing values
  res@lbLabelAutoStride=True ; ensure labels do not overlap
  res@gsnAddCyclic=False 

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap
  res@tiMainString = file_name

  plot=gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first
end

