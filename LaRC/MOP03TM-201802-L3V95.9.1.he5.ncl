;
; This example code illustrates how to access and visualize LaRC ASDC MOPITT 
; (MOP03TM) version 9 HDF-EOS5 Grid file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
; Usage:  save this script and run
;
;    $ncl MOP03TM-201802-L3V95.9.1.he5.ncl
;
; The HDF file must be in your current working directory.
;
; Tested under: NCL 6.6.2
; Last updated: 2021-11-11

begin
  file_name= "MOP03TM-201802-L3V95.9.1.he5"
  eos_file=addfile(file_name, "r")

  ; Show the file content.
  ; print(eos_file)

  data=eos_file->RetrievedSurfaceTemperatureDay_MOP03

  ; Data is transposed.
  dataT=transpose(data)

  xwks = gsn_open_wks("png", file_name+".ncl") ; open workstation
  gsn_define_colormap(xwks,"amwg")

  res=True
  res@gsnMaximize=True
  res@gsnPaperOrientation = "portrait"
  res@gsnSpreadColors=True
  res@tiMainString = file_name
  res@cnFillOn=True
  res@cnLinesOn=False
  res@cnLineLabelsOn =  False
  res@lbOrientation="vertical"
  res@cnFillMode="RasterFill"
  res@lbLabelAutoStride= True

  ; Data is stored upside-down.
  res@sfYArray = eos_file->Latitude_MOP03
  plot=gsn_csm_contour_map(xwks,dataT,res)
end
