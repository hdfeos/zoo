;
;  This example code illustrates how to access and visualize GES DISC
; TROPICS06 L2B netCDF-4/HDF5 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please use
; the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage: save this script and run
;
; $ncl TROPICS06.MIRS.L2B.Orbit04435.V02-06.ST20240224-162719.ET20240224-180211.CT20240325-020618.nc.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2024-05-31

begin
  file_name = "TROPICS06.MIRS.L2B.Orbit04435.V02-06.ST20240224-162719.ET20240224-180211.CT20240325-020618.nc"

; Read file. 
  eos_file = addfile(file_name, "r")

;  print(eos_file)

  data = short2flt(eos_file->TPW)
  lon = eos_file->Longitude
  lat = eos_file->Latitude

  data@lat2d = lat
  data@lon2d = lon
  
  xwks = gsn_open_wks("png", file_name+".ncl")
  res = True 
  res@cnFillOn = True
  res@gsnMaximize = True
  res@cnLinesOn = False
  res@cnLineLabelsOn = False
  res@gsnSpreadColors = True
  res@cnFillMode = "RasterFill"
  res@lbOrientation = "vertical"
  res@cnMissingValFillPattern = 0
  res@lbLabelAutoStride = True
  res@tiMainString = file_name
  res@trGridType = "TriangularMesh"
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")
  plot = gsn_csm_contour_map_ce(xwks,data,res)
end
