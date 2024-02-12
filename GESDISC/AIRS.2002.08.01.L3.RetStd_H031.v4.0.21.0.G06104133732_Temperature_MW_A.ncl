;This example code illustrates how to access and visualize GESDISC_AIRS Grid in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

; This is an example of a 3-D grid file data field at various levels.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.


begin
  eos_file=addfile("AIRS.2002.08.01.L3.RetStd_H031.v4.0.21.0.G06104133732.hdf.he2", "r") ; Read file. 
;To read HDF-EOS2 files, .he2 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

  data=eos_file->Temperature_MW_A_ascending_MW_only(0,:,:) ; read specific subset of data field
; In order to read the Temperature_MW_A data field from the HDF-EOS2 file, the group
; under which the data field is placed must be appended to the data field in NCL. For more information,
; visit section 4.3.2 of http://hdfeos.org/software/ncl.php.


  data@lon2d=eos_file->Longitude_location ; associate longitude and latitude
  data@lat2d=eos_file->Latitude_location
  data@_FillValue=-9999
; See "AIRS Version 5.0 Released Files Description" document [1]
; for unit specification.
  data@unit = "K"

  data_1=eos_file->Temperature_MW_A_ascending_MW_only(4,:,:)
  data_1@lon2d=eos_file->Longitude_location
  data_1@lat2d=eos_file->Latitude_location
  data_1@_FillValue=-9999
  data_1@unit = "K"

  data_2=eos_file->Temperature_MW_A_ascending_MW_only(8,:,:)
  data_2@lon2d=eos_file->Longitude_location
  data_2@lat2d=eos_file->Latitude_location
  data_2@_FillValue=-9999
  data_2@unit = "K"

  data_3=eos_file->Temperature_MW_A_ascending_MW_only(11,:,:)
  data_3@lon2d=eos_file->Longitude_location
  data_3@lat2d=eos_file->Latitude_location
  data_3@_FillValue=-9999
  data_3@unit = "K"

  xwks=gsn_open_wks("pdf","AIRS.2002.08.01.L3.RetStd_H031.v4.0.21.0.G06104133732_Temperature_MW_A") ; open workstation


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

  res@cnLevelSelectionMode="ManualLevels"; preset range defined to ensure uniform color legend across all levels
  res@cnLevelSpacingF=10 ; set interval
  res@cnMinLevelValF=180 ; set min and max values
  res@cnMaxLevelValF=330




  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  plot=new(4, "graphic") ; allocate plot

  res@tiMainString= "AIRS.2002.08.01.L3.RetStd_H031.v4.0.21.0.G06104133732.pdf" ; create title
  res@gsnCenterString="Temperature_MW_A at TempPrsLvls=0" ; create center text
  plot(0)=gsn_csm_contour_map_ce(xwks,data,res) ; plot 
  delete(res@tiMainString) ; delete title for subsequent plots

  res@gsnCenterString="Temperature_MW_A at TempPrsLvls=4"
  plot(1)=gsn_csm_contour_map_ce(xwks,data_1,res)

  res@gsnCenterString="Temperature_MW_A at TempPrsLvls=8"
  plot(2)=gsn_csm_contour_map_ce(xwks,data_2,res)

  res@gsnCenterString="Temperature_MW_A at TempPrsLvls=11"
  plot(3)=gsn_csm_contour_map_ce(xwks,data_3,res)



  delete(plot) ; cleaning up resources used
  delete(data)
  delete(data_1)
  delete(data_2)
  delete(data_3)
  delete(res)
  delete(eos_file)
end

; References
; [1] http://disc.sci.gsfc.nasa.gov/AIRS/documentation/v5_docs/AIRS_V5_Release_User_Docs/V5_Released_ProcFileDesc.pdf

