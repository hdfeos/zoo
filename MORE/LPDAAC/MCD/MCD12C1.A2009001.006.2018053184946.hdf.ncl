;
;  This example code illustrates how to access and visualize LP DAAC MCD12C1
; Grid file in NCL. 
;
;  If you have any questions, suggestions, comments  on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Tested under: NCL 6.6.2
; Last updated: 2021-10-06

; This is an example of a 3-D grid file data field at various levels.
begin

; Set file name to read.  
  file_name = "MCD12C1.A2009001.006.2018053184946.hdf"

; Read file. 
; To read HDF-EOS2 files, .he2 is appended to the file name argument. 
; For more information, consult section 4.3.2 of [1].
  eos_file=addfile(file_name+".he2", "r")

; Uncomment the following line to print all variables and attributes.
;  print(eos_file)

; Rad the same file as an HDF4 file to retrieve attributes.
  hdf4_file = addfile(file_name, "r")
; Uncomment the following line to print all variables and attributes.
;  print(hdf4_file)

; Read all necessary attributes.
  data_hdf4=hdf4_file->Land_Cover_Type_1_Percent


; Read data field.
  data3D=eos_file->Land_Cover_Type_1_Percent_MOD12C1

; Subset Class 1 of IGBP (Type 1) - Evergreen Needleleaf forest - using the 
; product description.
  data = data3D(:,:,1)
  data@long_name = data_hdf4@long_name + " - " + data_hdf4@Layer_1;
  data@unit = data_hdf4@units;

  xwks=gsn_open_wks("png", file_name + ".ncl") ; open workstation 

; These plot needs more memory since the array size is big.
  setvalues NhlGetWorkspaceObjectId() ; make maximum filesize larger
  "wsMaximumSize" : 200000000
  end setvalues

  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@cnLinesOn=False ; turn off contour lines
  res@gsnMaximize=True ; use entire page
  res@gsnPaperOrientation="Portrait" ; force portrait
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbLabelAutoStride=True ; ensure labels do not overlap
  res@lbOrientation = "vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0; white color for missing values
  res@tiMainString=file_name 
  res@gsnLeftStringFontHeightF=12 ; make text smaller
  res@gsnRightStringFontHeightF=12

; Define colormap that gives white color for 0 percent.
  gsn_define_colormap(xwks,"WhBlGrYeRe")
  plot=gsn_csm_contour_map_ce(xwks,data,res)  
end

; References
; [1] http://hdfeos.org/software/ncl.php
