; 
;  This example code illustrates how to access and visualize LaRC CERES 
; ISCCP D2like GEO Day Edition3A HDF4 file in NCL. 
;
;  If you have any questions, suggestions, comments  on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; $ncl CER_ISCCP-D2like-GEO_DAY_Edition3A_300300.201612.hdf.ncl
;
; Tested under: NCL 6.4.0
; Last updated: 2018-08-09

begin
  file_name = "CER_ISCCP-D2like-GEO_DAY_Edition3A_300300.201612.hdf"
  
; Read file. 
  hdf_file = addfile(file_name, "r") 

; Important! The following line prints all variables and attributes.
;  print(hdf_file) 

  data = hdf_file->Liquid_Effective_Temperature_Cumulus_M(0,:,:)

  data!0 = "lat"
  data!1 = "lon"

  lat = 90. - hdf_file->Colatitude_M(0,:,0)
  lon = hdf_file->Longitude_M(0,0,:)

; Make the plot be shown continously. Otherwise, it will be shifted.
  lon = where(lon.gt.180, lon-360, lon)

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

  delete(plot) ; cleaning up resources used
  delete(xwks)
  delete(data)
  delete(res)
  delete(hdf_file)
end

