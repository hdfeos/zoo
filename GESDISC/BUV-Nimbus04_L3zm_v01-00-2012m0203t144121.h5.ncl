; 
;  This example code illustrates how to access and visualize GESDISC MEaSUREs
; Ozone Zonal Average HDF5 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.0.0
; Last updated: 2012-10-17


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
; Read file. 
  file_name = "BUV-Nimbus04_L3zm_v01-00-2012m0203t144121.h5";
  h5_file=addfile(file_name, "r") 

; See what variables are available.
;  print(h5_file)
  data = h5_file->ProfileOzone
  datas = data(0,:,:)

; Latitude
  lat = h5_file->Latitude

; Pressure
  lev = h5_file->ProfilePressureLevels

; Date
  date = h5_file->Date

; Associate data with coordinate variables.
  datas&DIM_005 = lev
  datas&DIM_001 = lat

; Add time information to long_name for plot.
  datas@long_name = data@long_name + "~C~(Date=" + date(0) + ")"
  xwks = gsn_open_wks ("pdf", file_name + ".ncl")    ; open workstation
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")


  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn = False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@lbOrientation = "vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0; white color for missing values
  res@lbLabelAutoStride = True ; ensure no label overlap
  res@tiMainString = file_name

; Put Pressure on Y-axis and Latitude on X-axis by naming dimension.
  plot=gsn_csm_contour(xwks, datas(DIM_005|:,DIM_001|:), res) 

  delete(plot)
  delete(res)
  delete(xwks)
  delete(lev)
  delete(lat)
  delete(datas)
  delete(data)
  delete(h5_file)
end


