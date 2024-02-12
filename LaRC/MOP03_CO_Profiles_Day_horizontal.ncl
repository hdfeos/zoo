;This example code illustrates how to access and visualize LaRC_MOPITT Grid file in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 3-D grid file data field shown as a horizontal cross section.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin

  eos_file = addfile("MOP03-20000303-L3V1.0.1.hdf.he2", "r") ; Read file. 

  data = eos_file->CO_Profiles_Day_MOP03(111,:,:) ;read data field
  data@lat1d = eos_file->Latitude_MOP03;
  data@lon1d = eos_file->Longitude_MOP03;
  data@_FillValue = -9999;

  XDim = eos_file->Longitude_MOP03
  press = eos_file->Pressure_Grid_MOP03

  data&nlon_MOP03 = XDim ; assign coordinates for X and Y axis
  data&nprs_MOP03 = press ; 
; printVarSummary(data)

  xwks = gsn_open_wks("pdf","MOP03-20000303-L3V1.0.1_CO_Profiles_Day_horizontal.ncl") ; open workstation

  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn =  False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@lbOrientation = "vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0; white color for missing values
  res@lbLabelAutoStride = True ; ensure no label overlap
; res@gsnLeftStringFontHeightF = 12 ; make text smaller
  res@gsnCenterStringFontHeightF = 12
  res@gsnRightStringFontHeightF = 12

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  res@tiMainString = "MOP03-20000303-L3V1.0.1.hdf" ; create title
  res@tiYAxisString = "pressure" ; create axis strings
  res@tiXAxisString = "longitude"
  res@trYReverse = True ; reverse y-axis

  res@gsnCenterString = "CO_Profiles_Day at YDim=111" ; create left text

; Unit is ppbv according to spec. It's not in file itself. 
; See spec at http://www.acd.ucar.edu/mopitt/file-spec.shtml#L3
  res@gsnRightString = "Units: ppbv" ; create right text

  plot = gsn_csm_contour(xwks,data(nprs_MOP03|:,nlon_MOP03|:),res) ; plot with reordered axis

  delete(plot) ; cleaning up resources used
  delete(xwks)
  delete(data)
  delete(res)
  delete(eos_file)

end