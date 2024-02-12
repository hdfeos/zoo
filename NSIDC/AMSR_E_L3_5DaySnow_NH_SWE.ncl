;  This example code illustrates how to access and visualize NSIDC AMSR-E
; LAMAZ EASE Grid file in NCL.
;
;  If you have any questions, suggestions, comments on this example,
; please use the HDF-EOS Forum (http://hdfeos.org/forums).
;
;   If you would like to see an  example of any other NASA HDF/HDF-EOS
; data product that is not listed in the HDF-EOS Comprehensive Examples page
; (http://hdfeos.org/zoo), ;feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Assistance was provided by Dennis Shea of the
; University Corporation for Atmospheric Research (UCAR) and Wei Huang VETS/CISL
; of the National Center for Atmospheric Research (NCAR), Boulder, CO via the
; ncl-talk mailing list:  http://mailman.ucar.edu/mailman/listinfo/ncl-talk

; Tested under: NCL 6.0.0
; Last updated: 2011-10-06

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"


begin
 file_name = "AMSR_E_L3_5DaySnow_V09_20050126.hdf"

; Read file.
; To read HDF-EOS2 files, .he2 is appended to the argument.
; For more information, consult section 4.3.2 of [1].

 eos_file = addfile(file_name + ".he2", "r") 

; Print information about the file to know what variables and attributes are 
; available for plotting.
 print(eos_file)

; In order to read the SWE_NorthernPentad data field from the HDF-EOS2 file,
; the group under which the data field is placed must be appended to the data
; field in NCL.  For more information, visit section 4.3.2 of [1]
  eos_data=eos_file->SWE_NorthernPentad_Northern_Hemisphere

  printVarSummary(eos_data)

; Read file as an HDF4 file to retrieve attributes.
  hdf_file = addfile(file_name, "r") 

; Print all variables and attributes.
  print(hdf_file) 

; Read the dataset.
  hdf_data = hdf_file->SWE_NorthernPentad

; Filter out invalid range values.
; See "Table 2. Pixel Values ofr the SWE Feids" from [2].
  hdf_data = where(hdf_data .gt. 240, hdf_data@_FillValue, hdf_data)

; Prepare data for plotting by converting type.
  dataf = tofloat(hdf_data)
  dataf@_FillValue = tofloat(hdf_data@_FillValue)

; Multiply by two according to data spec [2].
  dataf = 2 * dataf

; You can get the description of data set from the data spec [2].
  dataf@long_name = "Northern Hemisphere 5-day Snow Water Equivalent ~C~ (" + hdf_data@hdf_name + ")"
  dataf@units = "mm"

; Read longitude and latitude from the LAMAZ EASE GRID.
  lon2d=eos_file->GridLon_Northern_Hemisphere
  lat2d=eos_file->GridLat_Northern_Hemisphere

; Process NAN (1e51) fillValue for LAMAZ geolocation.
  lon2d=where(lon2d .gt. 1000, -999.0, lon2d)
  lat2d=where(lat2d .gt. 1000, -999.0, lat2d)
  lon2d@_FillValue = -999.0
  lat2d@_FillValue = -999.0

; Associate data with lat/lon.
  dataf@lon2d = lon2d
  dataf@lat2d = lat2d

; Open workstation
  xwks=gsn_open_wks("pdf","AMSR_E_L3_5DaySnow_V09_20050126_SWE_NH")

  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@gsnMaximize=True; make plot large
  res@gsnPaperOrientation =       "portrait" ; force portrait orientation
  res@cnLinesOn=False ; turn off contour lines
  res@cnLineLabelsOn       =  False; turn off contour line labels
  res@lbLabelAutoStride       = True        ; let NCL decide on labels
  res@gsnSpreadColors=True ; use the entire color spectrum

; res@cnFillMode="RasterFill" ; faster -- but possibly unreliable
  res@cnFillMode              = "CellFill"
  res@trGridType              = "triangularmesh"

  res@lbOrientation="vertical" ;vertical labels

  res@mpProjection = "LambertEqualArea" ; LAMAZ
  res@mpCenterLatF = 90.0; == North Pole
  res@gsnPolar = "NH" ; plot northern hemisphere
  res@mpCenterLonF = 0.0

  res@mpLimitMode = "latlon"
  res@mpEllipticalBoundary  = True

; For zoomed-in view, limit the latitude.
  res@mpMinLatF = 20.0

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
  res@tiMainString = file_name ; create title
  plot=gsn_csm_contour_map(xwks,dataf,res) ; create plot

; Clean up resources.
  delete(plot) 
  delete(res)
  delete(xwks)
  delete(dataf)
  delete(hdf_data)
  delete(hdf_file)
  delete(eos_data)
  delete(eos_file)
end

; References
;
; [1] http://hdfeos.org/software/ncl.php
; [2] http://nsidc.org/data/docs/daac/ae_swe_ease-grids.gd.html