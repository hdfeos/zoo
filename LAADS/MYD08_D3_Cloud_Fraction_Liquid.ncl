;  This example code illustrates how to access and visualize LAADS MYD08 file
; in  NCL. 
;
;  If you have any questions, suggestions, comments  on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Tested under: NCL 6.0.0
; Last updated: 2011-09-28 


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

begin
  file_name = "MYD08_D3.A2009001.005.2009048010832.hdf"

; Read file. 
; To read HDF-EOS2 files, .he2 is appended to the file name argument. 
; For more information, consult section 4.3.2 of [1].
  eos_file=addfile(file_name + ".he2", "r") 

; Uncomment the following line to print all variables and attributes.
;  print(eos_file)

; Rad the same file as an HDF4 file to retrieve attributes.
  hdf4_file = addfile(file_name, "r")

; Uncomment to the following line to print all variables and attributes.
;  print(hdf4_file)

; Read data field.
  data_unscaled=eos_file->Cloud_Fraction_Liquid_mod08
  data_hdf4 = hdf4_file->Cloud_Fraction_Liquid
  data_unscaled@_FillValue = data_hdf4@_FillValue

; Filter out invalid values and set them as fill value.
  data_valid=where(data_unscaled.lt.data_hdf4@valid_range(0) .or. data_unscaled.gt.data_hdf4@valid_range(1), data_unscaled@_FillValue, data_unscaled)
  data_valid@_FillValue = data_unscaled@_FillValue

; Apply scale factor and offset according to the specification [2].
  data = (data_valid - data_hdf4@add_offset) * data_hdf4@scale_factor
  copy_VarCoords(data_unscaled, data)
  data@unit = data_hdf4@units
  data@long_name = data_hdf4@long_name

  xwks=gsn_open_wks("pdf","MYD08_D3.A2009001.005.2009048010832_Cloud_Fraction_Liquid.ncl") ; open workstation

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
  res@gsnLeftStringFontHeightF = 11 ; make font smaller
  res@gsnRightStringFontHeightF = 11 ; make font smaller

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap
  res@tiMainString = file_name
  plot=gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first

; Clean up resources used.
  delete(plot) 
  delete(xwks)
  delete(data)
  delete(data_unscaled)
  delete(res)
  delete(eos_file)
end

; References
;
; [1] http://hdfeos.org/software/ncl.php
; [2] http://ladsweb.nascom.nasa.gov/filespecs/MOD08_D3.CDL.fs