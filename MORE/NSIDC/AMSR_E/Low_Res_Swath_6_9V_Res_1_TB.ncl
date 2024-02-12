;
;  This example code illustrates how to access and visualize NSIDC AMSR_E L2A
; Swath file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please use
; the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.1.0
; Last updated: 2013-07-15

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  file_name =  "AMSR_E_L2A_BrightnessTemperatures_V10_200501180027_D.hdf"
  eos_file=addfile(file_name, "r") ; Read file. 

; Print information about the file to know what variables and attributes are 
; available for plotting.
  print(eos_file)

; Pick a dataset to plot.
  data_raw=eos_file->6_9V_Res_1_TB_not_resampled

; Print information about the specific dataset.
 printVarSummary(data_raw)

; Set fill value manually since there's no fill value attribute.
 data_unscaled = tofloat(data_raw)
 data_unscaled@_FillValue = -32768

; Let's apply scale and offset.
;
; For this dataset, we can't use short2flt() function like below since it 
; computes scale*(data_unscaled - offset).
;
; data = short2flt_hdf(data_unscaled)
;
; For this data product, what we need is data*scale + offset. 
  data = tofloat(data_unscaled * data_raw@SCALE_FACTOR + data_raw@OFFSET)

; Copy the unit attribute and name.
  data@unit = data_raw@UNIT
  data@long_name = data_raw@hdf_name

; Associate longitude and latitude.
; This can be done by looking at the output of the previous "print(eos_file)"
; command.
; Among 3 Latitude/Longitude pairs, pick one that matches the dimension names.
  data@lon2d=eos_file->Longitude__0
  data@lat2d=eos_file->Latitude__0

; Open workstation
  xwks=gsn_open_wks("pdf","Low_Res_Swath_6_9V_Res_1_TB")
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

  res@mpLimitMode         = "LatLon"
  res@mpMinLatF	= min(data@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
  res@mpMaxLatF	= max(data@lat2d) ; 
  res@mpMinLonF	= min(data@lon2d) ;
  res@mpMaxLonF	= max(data@lon2d) ;


  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  res@tiMainString=file_name
  plot=gsn_csm_contour_map_ce(xwks,data,res)


  delete(plot) ; cleaning up resources used
  delete(res)
  delete(data)
  delete(data_unscaled)
  delete(data_raw)
  delete(eos_file)
end
