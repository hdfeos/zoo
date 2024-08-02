; 
; This example code illustrates how to access and visualize LAADS VNP14
; v2 netCDF-4/HDF5 Swath file in NCL.
;
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
; $ncl VNP14IMG.A2018064.1200.002.2024079084304.nc.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2024-08-01

; This function is borrowed from the NCL website [1].
undef("span_color_indexes")
function span_color_indexes(cnlvls[*]:numeric,cmapt)
local ncols, lcount, fmin, fmax, fcols, icols, cmap
begin
  if(isstring(cmapt)) then
     cmap = read_colormap_file(cmapt)
  else if(isnumeric(cmapt)) then
    dims = dimsizes(cmapt)
    if(dims(0).lt.3.or.dims(0).gt.256.or..not.any(dims(1).ne.(/3,4/))) then
      print ("Error: span_color_indexex: cmap must be an n x 3 or n x 4 array of RGB or RGBA values, or a valid color map name")
      return(new(1,integer))   ; return missing
    end if
    cmap = cmapt
  else
    print ("Error: span_color_indexex: cmap must be an n x 3 or n x 4 array of RGB or RGBA values, or a valid color map name")
  end if
  end if

  ncols  = dimsizes(cmap(:,0))
  lcount = dimsizes(cnlvls)

; Start at index 0 and end at ncols-1 (the full range of the
; color map.
  minix = 0
  maxix = ncols-1

  fmin = new(1,float)    ; to make sure we get a missing value (?)
  fmax = new(1,float)
  fmin = minix
  fmax = maxix
  fcols = fspan(fmin,fmax,lcount+1)
  icols = tointeger(fcols + 0.5)
  return(icols)
end

begin
; Read file.
  file_name = "VNP14IMG.A2018064.1200.002.2024079084304.nc"
  nc4_file = addfile(file_name, "r")

; Print metadata information.
;  print(nc4_file)
  data = nc4_file->FP_T5
  lat = nc4_file->FP_latitude
  lon = nc4_file->FP_longitude
  lat@units = "degrees_north"
  lon@units = "degrees_east"

; Use 10 levels to use for grouping data values
  levels = fspan(min(data), max(data),10)
  nlevels  = dimsizes(levels)

  wks = gsn_open_wks("png", file_name+".ncl")
  colormap = "WhViBlGrYeOrRe"
  gsn_define_colormap(wks,colormap)
  cmap = gsn_retrieve_colormap(wks)

; Get a nice span of colors through the current color map, but
; skip the first three colors (0-2).
  colors = span_color_indexes(levels,cmap(3:,:))+3

; Create a map plot for which to add color-coded markers.
  mpres                       = True

  mpres@gsnMaximize           = True   ; maximize size of plot in window
  mpres@gsnDraw               = False  ; turn off draw
  mpres@gsnFrame              = False  ; turn off page advance

  mpres@gsnLeftString = data@long_name ; create left text
  mpres@gsnLeftStringFontHeightF=0.01  
; NCL 6.4.0 puts trailing garbage characters.
  mpres@gsnRightString = data@units
; Set it manually.
;  mpres@gsnRightString = "kelvins"
  mpres@gsnRightStringFontHeightF=0.01

  mpres@mpProjection = "Orthographic"
  mpres@mpGridAndLimbOn = True

  mpres@pmTickMarkDisplayMode = "Always"

  mpres@tiMainString          = file_name
  
  dimsize=dimsizes(data)
  n=dimsize(0)   
  mpres@mpCenterLonF = lon(n/2)
  mpres@mpCenterLatF = lat(n/2)  
  map = gsn_csm_map(wks,mpres)

; Group the data values according to which range they fall
; in, and attach them to the map as a colored marker.
  mkres               = True
  mkres@gsMarkerIndex = 16        ; filled dot
  mkres@gsMarkerSizeF = 0.002
  markerid = new(nlevels+1,graphic)

  do i=0,nlevels
    if(i.eq.0) then                         ; first level
      ii := ind(data.lt.levels(0))
    else if(i.eq.nlevels) then              ; middle levels
      ii := ind(data.ge.levels(nlevels-1))
    else                                    ; last level
      ii := ind(data.ge.levels(i-1).and.data.lt.levels(i))
    end if
    end if    
    if(.not.any(ismissing(ii))) then
      mkres@gsMarkerColor = colors(i)
      markerid(i) = gsn_add_polymarker(wks,map,lon(ii),lat(ii),mkres)
    end if
  end do

  draw(map)   ; This will draw map and the attached markers

; Draw a labelbar
;----------------------------------------------------------------------
  lbres                    = True
  lbres@vpWidthF           = 0.05             ; width
  lbres@vpHeightF          = 0.80             ; height
  lbres@lbPerimOn          = False            ; Turn off perimeter.
  lbres@lbLabelAlignment   = "InteriorEdges"  ; Default is "BoxCenters".
  lbres@lbFillColors       = colors           ; Colors for boxes.
  lbres@lbMonoFillPattern  = True             ; Fill them all solid.
  lbres@lbLabelFontHeightF = 0.012            ; label font height
  lbres@lbOrientation = "vertical" ; vertical labels

  labels = sprintf("%3.1f",levels)
  gsn_labelbar_ndc(wks,nlevels+1,labels,0.92,0.85,lbres) 
  frame(wks)
end

; References
;
;  [1] http://www.ncl.ucar.edu/Applications/Scripts/polyg_17.ncl