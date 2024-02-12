;
;   This example code illustrates how to access and visualize NSIDC SMAP
; L2 HDF5 file in NCL. 
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
; $ncl SMAP_L2_SM_P_03721_D_20151013T000528_R11920_001.h5.ncl
; Tested under: NCL 6.3.0
; Last updated: 2015-12-31

 
load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

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

; This is the main program.
begin
  file_name = "SMAP_L2_SM_P_03721_D_20151013T000528_R11920_001.h5"


; Without the following option, segmentation fault occurs in NCL 6.3.0.
; If you don't want this option, use 'ncl -f'.
  setfileoption("h5", "FileStructure", "Advanced")

; Read file as an HDF5 file. 
  h5_file = addfile(file_name, "r") 

;  print(h5_file)
  lat = h5_file->latitude
  lon = h5_file->longitude

  data_raw = h5_file->soil_moisture
  data = where(data_raw.gt.data_raw@valid_min .and. data_raw.lt.data_raw@valid_max, data_raw, data_raw@_FillValue)
  data@long_name = data_raw@long_name
  data@units = data_raw@units

;  printVarSummary(data)

; Use 10 levels to use for grouping data values
  levels = fspan(min(data), max(data),10)
  nlevels  = dimsizes(levels)

  wks = gsn_open_wks("png", file_name+".ncl") ; open workstation
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

  mpres@tiMainString          = file_name
  mpres@gsnLeftString = "FIELD:" + data@long_name ; create left text
  mpres@gsnRightString = "UNITS:" + data@units
  mpres@pmTickMarkDisplayMode = "Always"    ; Nicer map tickmarks
  mpres@gsnLeftStringFontHeightF = 12 ; make font smaller 
  mpres@gsnRightStringFontHeightF = 12 ; make font smaller   

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
  lbres@vpWidthF           = 0.80             ; width
  lbres@vpHeightF          = 0.10             ; height
  lbres@lbPerimOn          = False            ; Turn off perimeter.
  lbres@lbOrientation      = "Horizontal"     ; Default is vertical.
  lbres@lbLabelAlignment   = "InteriorEdges"  ; Default is "BoxCenters".
  lbres@lbFillColors       = colors           ; Colors for boxes.
  lbres@lbMonoFillPattern  = True             ; Fill them all solid.
  lbres@lbLabelFontHeightF = 0.012            ; label font height

  labels = sprintf("%e",levels)
  gsn_labelbar_ndc (wks,nlevels+1,labels,0.1,0.23,lbres) 

  frame(wks)

  delete(wks)
  delete(data)
  delete(lat)
  delete(lon)
  delete(mpres)
  delete(lbres)
  delete(h5_file)
end

; References
;
;  [1] http://www.ncl.ucar.edu/Applications/Scripts/polyg_17.ncl