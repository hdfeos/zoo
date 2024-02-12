;  This example code illustrates how to access and visualize NSIDC MOD29 Grid 
; file in NCL. This file uses LAMAZ projection.
;
;  If you have any questions, suggestions, comments  on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Example HDF File source:
; ftp://ftp.hdfgroup.uiuc.edu/pub/outgoing/NASAHDF/
;       MOD29E1D.A2000055.005.2006268025009.hdf

; Original File Source:
; ftp://n4ftl01u.ecs.nasa.gov/SAN/MOST/MOD29E1D.005/2000.02.24/
;       MOD29E1D.A2000055.005.2006268025009.hdf
; File Metadata:
;       MOD29E1D.A2000055.005.2006268025009.hdf.xml
; Browse images:
;       BROWSE.MOD29E1D.A2000055.005.2006268025009.[1-4].jpg

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
; To read HDF-EOS2 files, the file extension ".hdf" can be appended with ".he2"
; in the call to addfile().  The HDF file does not need to be renamed.
; For more information, consult section 4.3.2 of 
; http://hdfeos.org/software/ncl.php.

  filename = "MOD29E1D.A2000055.005.2006268025009.hdf.he2"
  eos_file=addfile(filename, "r") 

; Read data from file. Original data is 4501x4501.  We can sub-sample
  data =eos_file->Sea_Ice_by_Reflectance_NP_MOD_Grid_Seaice_4km_North(::7,::7)
  dimsize = dimsizes(data)
  nlon = dimsize(0)
  nlat = dimsize(1)

; ncl_filedump of MOD29E1D.A2000055.005.2006268025009.hdf.he2 shows:
; GridLat/Lon_MOD_Grid_Seaice_4km_North
; corners :      ( 1e+51, 1e+51, 1e+51, 1e+51 )
; this is a bug in the GCTP library
; To properly display the data, the latitude/longitude must be remapped.
; however, this data cannot be subset
; lat=asciiread("lat_MOD29E1D.A2000055.005.2006268025009.MOD_Grid_Seaice_4km_North.output",(/nlon,nlat/),"float")
; lon=asciiread("lon_MOD29E1D.A2000055.005.2006268025009.MOD_Grid_Seaice_4km_North.output",(/nlon,nlat/),"float")

; compute longitude and latitude from the LAMAZ EASE GRID
lon2d=eos_file->GridLon_MOD_Grid_Seaice_4km_North(::7,::7)
lat2d=eos_file->GridLat_MOD_Grid_Seaice_4km_North(::7,::7)

; process NAN (1e51) fillValue for LAMAZ geolocation
lon2d=where(lon2d .gt. 1000, -999.0, lon2d)
lat2d=where(lat2d .gt. 1000, -999.0, lat2d)
lon2d@_FillValue = -999.0
lat2d@_FillValue = -999.0


  data@lat2d=lat2d
  data@lon2d=lon2d
  data@long_name = data@hdfeos_name 

  xwks=gsn_open_wks("pdf", "MOD29E1D.A2000055.005.2006268025009.hdf.Sea_Ice_by_Reflectance_NP.ncl") ; open workstation

  res=True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn = False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0; white color for missing values

; Set explicit contour levels.
  res@cnLevelSelectionMode = "ExplicitLevels" 
  res@cnLevels = (/1,11,25,37,39,50,200,253,254,255/)

  res@lbLabelPosition = "Center"    
  res@lbLabelAlignment = "BoxCenters"
; You can get this list from the field's "Key" attribute using HDFView.
  res@lbLabelStrings = (/"miss","no","night","land","water","ocean","cloud","ice","empty","mask","fill"/)
; Give an explanation about the shortened labels above.
  res@lbTitleString = (/"miss=missing, no=no decision, water=inland water, ice=sea ice, empty=no input tile expected, mask=non-production mask"/)
  res@lbTitlePosition = "Bottom"
; Make the font smaller so that the above long string can fit in one line.
  res@lbTitleFontHeightF = 0.008

; Plot northern hemisphere.
  res@gsnPolar = "NH" 

; This LAMAZ projection lat/lon spans over -90 to 90 and -180 and 180.
; To get a zoomed effect, limit the lat min to 30.
  res@mpMaxLatF = 30

; Choose colormap.
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

; Create the title with file name.
  res@tiMainString = filename 

; Create plot.
  plot=gsn_csm_contour_map(xwks,data,res)

; Clean up used resources.
  delete(plot) 
  delete(xwks)
  delete(data)
  delete(res)
  delete(eos_file)

end
