;
;  This example code illustrates how to access and visualize PO.DAAC MODIS
; L2P netCDF-4/HDF5 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage:
;
;   $ncl 20100619062008-JPL-L2P_GHRSST-SSTskin-MODIS_A-N-v02.0-fv01.0.nc.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2022-05-27

begin
; Read file. 
  file_name = "20100619062008-JPL-L2P_GHRSST-SSTskin-MODIS_A-N-v02.0-fv01.0.nc";
  h5_file=addfile(file_name, "r") 

; See what variables are available.
;  print(h5_file)

; Read Latitude.
  lat = h5_file->/lat

; Read Longitude.
  lon = h5_file->/lon

; Read dataset.
  data3D = h5_file->/sea_surface_temperature
  data = short2flt(data3D(0,:,:))

; Associate lat/lon with data.
  data@lat2d=lat
  data@lon2d=lon

  xwks=gsn_open_wks("png", file_name+".ncl") ; open workstation

  res=True 
  res@cnFillOn=True
  res@gsnMaximize=True
  res@cnLinesOn=False
  res@cnLineLabelsOn=False
  res@gsnSpreadColors=True
  res@cnFillMode="RasterFill"
  res@lbOrientation="vertical"
  res@cnMissingValFillPattern=0
  res@lbLabelAutoStride=True
  res@tiMainString=file_name
  res@trGridType = "TriangularMesh"
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap
  plot=gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first
end