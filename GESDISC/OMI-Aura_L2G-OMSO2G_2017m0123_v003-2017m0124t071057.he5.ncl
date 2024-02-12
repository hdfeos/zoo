;
;  This example code illustrates how to access and visualize HDF_EOS5 file in 
; NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Usage:save this script and run 
; 
; $ncl OMI-Aura_L2G-OMSO2G_2017m0123_v003-2017m0124t071057.he5.ncl
; Tested under: NCL 6.4.0
; Last updated: 2017-12-19

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"



begin
  file_name = "OMI-Aura_L2G-OMSO2G_2017m0123_v003-2017m0124t071057.he5"
  field_name = "CloudPressure"

; To read HDF-EOS5 files, the file extension must be ".he5".
  eos_file = addfile(file_name, "r") 

; List variables available for plots.
;  print(eos_file);

  data_raw=eos_file->ColumnAmountSO2_PBL_OMI_Total_Column_Amount_SO2

; Geo-location data contains fill values.
  lat_raw=eos_file->Latitude_OMI_Total_Column_Amount_SO2
  lon_raw=eos_file->Longitude_OMI_Total_Column_Amount_SO2

; NCL has a bug - ValidRange should be an array with two values -10 and 2000.
; However, NCL can read only the first one (i.e., -10).
; You can confirm it by printing the attribute value.
; print(data_raw@ValidRange)
  data_valid = where(data_raw.gt.data_raw@ValidRange(0) .and. data_raw.lt.2000, data_raw, data_raw@_FillValue)

; Subset at nCandidate=0.
  nCandidate = 0
  data=data_valid(nCandidate,:,:)
  lat=lat_raw(nCandidate,:,:)
  lon=lon_raw(nCandidate,:,:)
  data@long_name = data_raw@Title + " at nCandidate=" + nCandidate

  plot_name = file_name + ".ncl"
  xwks   = gsn_open_wks ("png", plot_name)    ; open workstation
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

  res=True
  res@gsnMaximize=True   ;make plot large
  res@gsnPaperOrientation = "landscape"    ;force portrait orientation
  res@gsnSpreadColors=True    ; use the entire color spectrum
  res@cnFillOn=True   ;enable contour fill
  res@cnLinesOn=False   ;turn off contour line
  res@cnLineLabelsOn =  False    ;turn off contour line labels
  res@cnFillMode="RasterFill"   ;faster
  res@lbLabelAutoStride= True
  res@lbOrientation="vertical" ;vertical labels
  res@tiMainString = file_name
  plot=gsn_csm_contour_map(xwks,data,res)

  delete(plot)
  delete(data)
  delete(res)
  delete(eos_file)
end
