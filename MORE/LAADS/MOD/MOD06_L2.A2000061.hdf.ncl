;
; This example code illustrates how to access and visualize four LAADS MOD06
; L2 Swath files in one plot using NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Acknowledgement
;
; This code is modified from the demo script by NCL group:
;   http://www.ncl.ucar.edu/Applications/Scripts/hdf4sds_5.ncl
;

; Tested under: NCL 6.1.2
; Last updated: 2014-1-24

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin 

; Read four MODIS HDF files.
  f = addfile("MOD06_L2.A2000061.0000.051.2010273191331.hdf","r")
  g = addfile("MOD06_L2.A2000061.0005.051.2010273190022.hdf","r")
  h = addfile("MOD06_L2.A2000061.0010.051.2010273184523.hdf","r")
  j = addfile("MOD06_L2.A2000061.0015.051.2010273183731.hdf","r")

; Read  cloud temperature.
  wv1s = f->Cloud_Top_Temperature
  wv2s = g->Cloud_Top_Temperature
  wv3s = h->Cloud_Top_Temperature
  wv4s = j->Cloud_Top_Temperature

; Apply scale and offset and convert to double.
  wv1 =  wv1s@scale_factor*1.d * (wv1s - wv1s@add_offset)
  wv2 =  wv2s@scale_factor*1.d * (wv2s - wv2s@add_offset)
  wv3 =  wv3s@scale_factor*1.d * (wv3s - wv3s@add_offset)
  wv4 =  wv4s@scale_factor*1.d * (wv4s - wv4s@add_offset)

; Extract start time from the first data in the first file.
  time_start = doubletoint(f->Scan_Start_Time(0,0))
  gdate_start  = cd_inv_calendar(1993,1,1,0,0,time_start(0),"seconds since 1993-01-01", 0)
  date2d_start = cd_calendar(gdate_start,0)
  date_start   = date2d_start(0,:) 

; Extract end time from the last data in the last file.
  time_end = doubletoint(j->Scan_Start_Time(405,269))
  gdate_end  = cd_inv_calendar(1993,1,1,0,0,time_end(0),"seconds since 1993-01-01", 0)
  date2d_end = cd_calendar(gdate_end,0)
  date_end   = date2d_end(0,:) 

  lat2d1    = f->Latitude
  lon2d1    = f->Longitude
  lat2d2    = g->Latitude
  lon2d2    = g->Longitude
  lat2d3    = h->Latitude
  lon2d3    = h->Longitude
  lat2d4    = j->Latitude
  lon2d4    = j->Longitude


; Start the graphics.
  wks = gsn_open_wks("png", "MOD06_L2.A2000061.hdf.ncl") 

; Choose colormap.
  gsn_define_colormap(wks,"rainbow+gray")        

; Set some resources that will apply to the base contour/map plot 
; that we are going to use to overlay the other contour plots on.
  res                      = True

  res@gsnMaximize          = True                ; maximize pot in frame
  res@gsnFrame             = False               ; don't advance frame
  res@gsnDraw              = False               ; don't draw plot


  res@cnFillOn             = True               ; color Fill 
  res@cnFillMode           = "CellFill"         ; Raster Mode
  res@cnRasterSmoothingOn  = True
  res@cnRasterMinCellSizeF = 0.0005
  res@cnLinesOn            = False              ; Turn off contour lines
  res@cnLineLabelsOn       = False              ; Turn off contour lines
  res@cnMaxLevelCount      = 100

  res@gsnSpreadColors      = True               ; use full colormap
  res@gsnSpreadColorStart  = 5
  res@gsnSpreadColorEnd    = -2

  res@trGridType                   = "TriangularMesh"

  res@gsnAddCyclic                 = False    ; Data is not cyclic


; Make a copy of the resources at this point, because these are 
; the resources we want to apply to the rest of the contour plots
; we're going to create later.
  res1 = res

; Set the rest of the resources that we only want to apply to
; the base map/contour plot.
  res@lbTitleString        = wv1s@long_name + " (" + wv1s@units + ")"
  res@lbTitleFontHeightF   = 0.015               ; Make font smaller
  res@lbLabelAutoStride    = True                ; Nice stride for labels
  res@lbLabelFontHeightF   = 0.012               ; Make labels bigger
  res@lbTitleOffsetF       = -0.3
  res@lbBoxLinesOn         = False

  res@mpDataBaseVersion   = "MediumRes"          ; Higher res coastline
  res@mpProjection        = "Orthographic"

; Set limits of map, based on the min/max of all four datasets.
  res@mpLimitMode         = "LatLon"
  res@mpMinLatF           = min((/lat2d1,lat2d2,lat2d3,lat2d4/)) 
  res@mpMaxLatF           = max((/lat2d1,lat2d2,lat2d3,lat2d4/))
  res@mpMinLonF           = min((/lon2d1,lon2d2,lon2d3,lon2d4/))
  res@mpMaxLonF           = max((/lon2d1,lon2d3,lon2d3,lon2d4/))

  res@mpGridAndLimbOn     = True

; Change map center to view all 4 datasets.
  res@mpCenterLonF        = 150         
  res@mpCenterLatF        = -50

  res@pmTickMarkDisplayMode        = "Always"
  date_start_str = date_start(0) + "/" + date_start(1) + "/" + date_start(2) + "-"+  date_start(3) + ":" + date_start(4) + ":" + date_start(5)
  date_end_str = date_end(0) + "/" + date_end(1) + "/" + date_end(2) + "-" +  date_end(3) + ":" + date_end(4) + ":" + date_end(5)

  res@tiMainString                 = "Four MODIS Swaths (MOD06_L2) ~C~from "+ date_start_str + " to " + date_end_str

  res@sfXArray             = lon2d1
  res@sfYArray             = lat2d1


; Create map/contour plot but don't draw it yet.
  plot = gsn_csm_contour_map(wks,wv1, res)


; Retrieve the contour levels used so we can set these for
; the remaining plots. We could have also set the contour
; levels above.
  getvalues plot@contour
    "cnMinLevelValF"  : minlevel
    "cnMaxLevelValF"  : maxlevel
    "cnLevelSpacingF" : levelspacing
  end getvalues  

  res1                      = True
  res1@cnLevelSelectionMode = "ManualLevels" ; Set manual contour levels
  res1@cnMinLevelValF       = minlevel
  res1@cnMaxLevelValF       = maxlevel
  res1@cnLevelSpacingF      = levelspacing
  res1@cnInfoLabelOn        = False
  res1@lbLabelBarOn         = False         ; Turn off b/c we already
                                            ; have one.

; Each new contour plot that we create we need to set
; the new 2D lat/lon arrays that correspond to this 
; dataset.
  res1@sfXArray             = lon2d2
  res1@sfYArray             = lat2d2

  plot2 = gsn_csm_contour(wks,wv2,res1)

  res1@sfXArray             = lon2d3
  res1@sfYArray             = lat2d3
  plot3 = gsn_csm_contour(wks,wv3,res1)

  res1@sfXArray             = lon2d4
  res1@sfYArray             = lat2d4
  plot4 = gsn_csm_contour(wks,wv4,res1)


; Overlay the 3 contour plots on the base map/contour plot.
; This works because we've set the sf*Array resources for each
; plot.
  overlay(plot,plot2)
  overlay(plot,plot3)
  overlay(plot,plot4)


; Drawing the base plot will cause all the overlaid plots 
; to be drawn as well.
  draw(plot)
  frame(wks)
end
