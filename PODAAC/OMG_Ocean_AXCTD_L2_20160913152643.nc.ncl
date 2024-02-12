;
;   This example code illustrates how to access and visualize PO.DAAC OMG AXCTD
; L2 netCDF-4/HDF5 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Usage:save this script and run 
; 
; $ncl OMG_Ocean_AXCTD_L2_20160913152643.nc.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2019-09-18

begin
  file_name="OMG_Ocean_AXCTD_L2_20160913152643.nc"
  eos_file=addfile(file_name, "r") ; Read file.
  
  data=eos_file->temperature
  depth=eos_file->depth
  lat=eos_file->lat
  lon=eos_file->lon
  
  xwks=gsn_open_wks("png", file_name+".ncl")    ; open workstation
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

  res=True
  res@gsnMaximize=True
  ; This is useful for plotting sea depth.
  res@trYReverse=True

  res@tiMainString=file_name
  res@gsnLeftString="Location: lat="+lat(0)+" lon="+lon(0)
  res@tiYAxisString=depth@long_name + " ("+depth@units+")"
  res@tiXAxisString=data@long_name + " ("+data@units+")"
  res@tmXBLabelFontHeightF=0.01

  plot=gsn_csm_xy(xwks,data, depth,res)
end


