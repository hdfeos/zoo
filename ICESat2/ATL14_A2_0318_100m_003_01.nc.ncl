;  This example code illustrates how to access and visualize NSIDC ATL14 v3
; Antarctic Polar Stereographic Grid netCDF-4 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage: save this script and run 
; 
; $ncl ATL14_A2_0318_100m_003_01.nc.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2024-04-02

begin
  file_name = "ATL14_A2_0318_100m_003_01.nc"
  eos_file = addfile(file_name, "r") ; Read file.

  file_name_aux = "ATL14_A2_0318_100m_003_01.aux.nc"
  aux_file = addfile(file_name_aux, "r") ; Read file.

; Dump the content of file.
;  print(eos_file)

; Subset data since it's huge.  
  data = eos_file->h(::100,::100)
  lon = aux_file->lon
  lat = aux_file->lat
  
; Associate longitude and latitude.
  data@lon2d = lon
  data@lat2d = lat

  xwks = gsn_open_wks("png", file_name+".ncl") ; open workstation

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
  res@gsnPolar = "SH" ; plot southern hemisphere
  res@mpMaxLatF = max(data@lat2d) 

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
  res@tiMainString = file_name ; create title
  plot=gsn_csm_contour_map(xwks, data, res) ; create plot
end