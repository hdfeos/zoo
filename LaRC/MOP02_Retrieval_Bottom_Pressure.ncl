;This example code illustrates how to access and visualize LaRC_MOPITT Swath file in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 2-D swath file data field with 1 dimensional coordinate variables.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin

  eos_file = addfile("MOP02-20000303-L2V5.7.1.val.hdf.he2", "r") ; Read file. 

  data = eos_file->Retrieval_Bottom_Pressure_MOP02(:,0) ; read data field subset

  xwks = gsn_open_wks("pdf","MOP02-20000303-L2V5.7.1.val_Retrieval_Bottom_Pressure.ncl") ; open workstation

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
  res@gsnLeftStringFontHeightF = 16 ; make text smaller
; res@gsnCenterStringFontHeightF = 16
  res@gsnRightStringFontHeightF = 16

  res@sfYArray = eos_file->Latitude_MOP02;
  res@sfXArray = eos_file->Longitude_MOP02;

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  res@tiMainString = "MOP02-20000303-L2V5.7.1.val.hdf" ; create title
  res@gsnLeftString = "Field name: Retrieval Bottom Pressure" ; create center text
; Unit is hPa according to spec. It's not in file itself. 
; See spec at http://www.acd.ucar.edu/mopitt/file-spec.shtml#L2
  res@gsnRightString = "Units: hPa" ; create right text

  plot = gsn_csm_contour_map_ce(xwks,data,res) ; 

  delete(plot) ; cleaning up resources used
  delete(xwks)
  delete(data)
  delete(res)
  delete(eos_file)

end