;
;   This example code illustrates how to access and visualize GES DISC AIRS v6
; Swath HDF-EOS2 file in NCL. 
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
; $ncl AIRS.2002.08.30.227.L2.RetStd_H.v6.0.12.0.G14101125810.hdf.ncl
;
; Tested under: NCL 6.3.0
; Last updated: 2016-11-22

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 2-D data field.
; We assume that users know how to obtain data field information from HDFView.
; For information about HDFView, visit [1].

begin

  file_name = "AIRS.2002.08.30.227.L2.RetStd_H.v6.0.12.0.G14101125810.hdf"

; To read HDF-EOS2 files, .he2 is appended to the argument.
; For more information, consult section 4.3.2 of [2].
  eos_file=addfile(file_name+".he2", "r") ; Read file.

; Read specific subset of data field.
  data=eos_file->topog_L2_Standard_atmospheric_surface_product(:,:)
  
; To read the topog data field from the HDF-EOS2 file, append the group name
; under which the data field is placed toe the data field name in
; NCL. For more information, visit section 4.3.2 of [2].

; Associate longitude and latitude.
  data@lat2d=eos_file->Latitude_L2_Standard_atmospheric_surface_product
  data@lon2d=eos_file->Longitude_L2_Standard_atmospheric_surface_product

; See AIRS L2 user guide [3] for unit specification.
  data@unit = "m"


  xwks=gsn_open_wks("png", file_name+".ncl")
  res=True 
  res@cnFillOn=True
  res@gsnMaximize=True
  res@gsnPaperOrientation="portrait"
  res@cnLinesOn=False
  res@cnLineLabelsOn=False
  res@gsnSpreadColors=True
  res@cnFillMode="RasterFill"
  res@lbOrientation="vertical"
  res@cnMissingValFillPattern=0
  res@cnMissingValFillColor=0


  res@mpLimitMode="LatLon"
  res@mpMinLatF=min(data@lat2d)
  res@mpMaxLatF=max(data@lat2d)
  res@gsnPolar   = "NH"

  gsn_define_colormap(xwks,"amwg")

  res@tiMainString=file_name
  data@long_name=data@hdfeos_name
  plot=gsn_csm_contour_map_polar(xwks,data,res)
  
  delete(res@tiMainString) 
  delete(plot)
  delete(data)
  delete(res)
  delete(eos_file)
end

; References
;
; [1] http://www.hdfgroup.org/hdf-java-html/hdfview/
; [2] http://hdfeos.org/software/ncl.php
; [3] http://disc.sci.gsfc.nasa.gov/AIRS/documentation/v6_docs/v6releasedocs-1/V6_L2_Product_User_Guide.pdf