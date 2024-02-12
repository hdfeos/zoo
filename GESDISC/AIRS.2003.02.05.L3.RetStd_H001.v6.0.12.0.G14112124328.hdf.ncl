;
;   This example code illustrates how to access and visualize GES DISC AIRS v6
; Grid HDF-EOS2 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage:save this script and run
;
; $ncl AIRS.2003.02.05.L3.RetStd_H001.v6.0.12.0.G14112124328.hdf.ncl
;
; Tested under: NCL 6.3.0
; Last updated: 2016-11-22


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 3-D grid file data field at various levels.
; We assume that users know how to obtain data field information from HDFView.
; For information about HDFView, visit [1].

begin
  
  file_name = "AIRS.2003.02.05.L3.RetStd_H001.v6.0.12.0.G14112124328.hdf"
  
; To read HDF-EOS2 files, .he2 is appended to the argument.
; For more information, consult section 4.3.2 of [2].
  eos_file=addfile(file_name+".he2", "r") ; Read file.  

; Read specific subset of data field.  
  data=eos_file->Temperature_MW_A_ascending_MW_only(0,:,:) 

; Associate longitude and latitude  
  data@lon2d=eos_file->Longitude_location
  data@lat2d=eos_file->Latitude_location

; See AIRS user's guide [3] for unit specification.
  data@unit = "K"
  data@long_name =data@hdfeos_name+" at TempPrsLvls=0"

  xwks=gsn_open_wks("png", file_name+".ncl")
  
  res=True
  res@cnFillOn=True
  res@gsnMaximize=True
  res@cnLinesOn=False
  res@cnLineLabelsOn=False
  res@gsnSpreadColors=True
  res@cnFillMode="RasterFill"
  res@lbOrientation="vertical"
  res@cnMissingValFillPattern=0
  res@cnMissingValFillColor=0

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  res@tiMainString=file_name
  plot=gsn_csm_contour_map_ce(xwks,data,res)
  
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
; [3] http://disc.sci.gsfc.nasa.gov/AIRS/documentation/v6_docs/v6releasedocs-1/V6_L3_User_Guide.pdf
