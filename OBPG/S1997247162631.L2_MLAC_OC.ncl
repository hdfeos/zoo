;
;  This example code illustrates how to access and visualize OBPG SeaWiFS HDF4 
; L2 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please use
; the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Tested under: NCL 6.0.0
; Last updated: 2012-12-20

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
; Since the file is not HDF-EOS2, it is not necessary to append .he2
; For more information, consult section 4.3.2 of 
; http://hdfeos.org/software/ncl.php.
  file_name = "S1997247162631.L2_MLAC_OC.hdf"

; Read file. 
  hdf4_file=addfile(file_name, "r") ; Read file. 

; Read the data field.
  data_pre=hdf4_file->Rrs_412 

; It is assumed users know how to obtain information such as _FillValue from 
; HDFView. For information about HDFView, visit 
; http://www.hdfgroup.org/hdf-java-html/hdfview/
  data_pre@_FillValue=-32767h


; The hdf4_file->Rrs_412 is 16-bit integer (type short)
; short2flt() will converts values of type short to values of type float 
; using the "scale" and "offset" attributes (if present). 
; See http://www.ncl.ucar.edu/Document/Functions/Contributed/short2flt.shtml
; short2flt() can handle the following scale and offset:
; scale: "SCALE", "Scale", "_scale", "scale_factor", "Scale_factor", "Slope",
;        "slope"
; offset: "add_offset", "OFFSET", "Offset", "_offset", "Intercept", "intercept"
;
; hdf4_file->Rrs_412 has attributes: slope and intercept, those attributes 
; can be handled by short2flt()
  data = short2flt(data_pre)

  data@lat2d=hdf4_file->latitude
  data@lon2d=hdf4_file->longitude

  data@long_name = data_pre@long_name
  data@units = data_pre@units

  xwks=gsn_open_wks("pdf", file_name) ; open workstation

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
  res@lbLabelAutoStride = True ; ensure no label overlap


  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap


; You should also make sure you have a .hluresfile in your home directory 
; so you don't get any PLCHHQ error messages.
; see: http://www.ncl.ucar.edu/Document/Graphics/hlures.shtml

  res@tiMainString = file_name


  plot=gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first


  delete(plot) ; cleaning up resources used
  delete(xwks)
  delete(data)
  delete(res)
  delete(hdf4_file)
end