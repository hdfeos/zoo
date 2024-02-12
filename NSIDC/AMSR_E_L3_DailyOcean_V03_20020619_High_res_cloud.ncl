;  This example code illustrates how to access and visualize NSIDC AMSR_E Grid 
; file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please use
; the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.0.0
; Last updated: 2011-10-04

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  file_name = "AMSR_E_L3_DailyOcean_V03_20020619.hdf"

; To read the file as an HDF-EOS2 file, .he2 is appended to the argument. 
; For more information, consult section 4.3.2 of [1]. 
  eos_file=addfile(file_name + ".he2", "r") ; Read file. 

; Print all variables and attributes.
;  print(eos_file)

; Read data field.
; In order to read the High_res_cloud data field from the HDF-EOS2 file, 
; the group under which the data field is placed must be appended to the data 
; field in NCL. For more information,
; visit section 4.3.2 of [1].
  data_eos = eos_file->High_res_cloud_GlobalGrid(:,:) 

; Read file as an HDF4 file to retrieve attributes.
  hdf_file = addfile(file_name, "r") 

; Print all variables and attributes.
;  print(hdf_file) 

  data_hdf = hdf_file->High_res_cloud

; Read fill value from data directly using HDFView.
  data_hdf@_FillValue = -9999h

; Convert short type to float.
  data = tofloat(data_hdf)

; Apply scale factor.
  data = data * data_hdf@Scale

; Set unit and name from attributes.
  data@units=data_hdf@Unit
  data@long_name = data_hdf@hdf_name
  copy_VarCoords(data_eos, data)

  xwks=gsn_open_wks("pdf","AMSR_E_L3_DailyOcean_V03_20020619_High_res_cloud.ncl") ; open workstation



  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@gsnMaximize=True; make plot large
  res@gsnPaperOrientation =	"portrait" ; force portrait orientation
  res@cnLinesOn=False ; turn off contour lines
  res@cnLineLabelsOn       =  False; turn off contour line labels
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbOrientation="vertical" ;vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0; white color for missing values


  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
  res@tiMainString = file_name
  plot=gsn_csm_contour_map_ce(xwks,data,res) ; create plot

  delete(plot) ; cleaning up used resources
  delete(res)
  delete(xwks)
  delete(data)
  delete(data_hdf)
  delete(hdf_file)
  delete(data_eos)
  delete(eos_file)
end

; References
;
; [1] http://hdfeos.org/software/ncl.php.