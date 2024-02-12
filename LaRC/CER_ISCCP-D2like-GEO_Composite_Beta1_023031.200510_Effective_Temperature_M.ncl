;  This example code illustrates how to access and visualize LaRC CERES 
; ISCCP HDF4 file in NCL. 

;
;  If you have any questions, suggestions, comments  on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Tested under: NCL 6.0.0
; Last updated: 2011-10-03

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"


begin
  file_name = "CER_ISCCP-D2like-GEO_Composite_Beta1_023031.200510.hdf"
; Read file. 
  hdf_file = addfile(file_name, "r") 

; Important! The following line prints all variables and attributes.
  print(hdf_file) 

  data = hdf_file->Effective_Temperature_M(0,0,:,:)

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

  xwks=gsn_open_wks("pdf","CER_ISCCP-D2like-GEO_Composite_Beta1_023031.200510_Effective_Temperature_M.ncl") ; open workstation 

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
  res@gsnAddCyclic=False ;;;;;

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  res@tiMainString = "CER_ISCCP-D2like-GEO_Composite_Beta1_023031.200510.hdf"

; You can use variable name and dimension name defined in hdf_file.
; :C: is a carriage return. It can be ~C~ if .hluresfile is used.

;  data@long_name = hdf_file->Effective_Temperature_M@hdf_name + ":C: at " + hdf_file->Effective_Temperature_M!0 + "=0 & " + hdf_file->Effective_Temperature_M!1 + "=0"

; However, we will use the meaningful description of data from data spec.
; See [1] for details.
  data@long_name = "Monthly Mean Effective Temperature of Cumulus"

  data@unit = hdf_file->Effective_Temperature_M@units


; gsn_csm_contour_map_ce() just uses geographic projection
; normally we should use gsn_csm_contour_map(), and use something like 
; res@mpProjection = "LambertEqualArea" to specify the map projection 
; however, by default, gsn_csm_contour_map() will use geographic projection
; i.e. cylindrical equidistant projection.
; See [2] for details.

  plot=gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first

  delete(plot) ; cleaning up resources used
  delete(xwks)
  delete(data)
  delete(res)
  delete(hdf_file)

end

; References
;
; [1] http://ceres.larc.nasa.gov/documents/DPC/DPC_current/pdfs/DPC_all.pdf
; [2] http://www.ncl.ucar.edu/Document/Graphics/Interfaces/gsn_csm_contour_map_ce.shtml