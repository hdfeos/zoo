;
;  This example code illustrates how to access and visualize LaRC CALIPSO Lidar
; Level 2 Vertical Feature Mask Version 3 HDF4 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please use
; the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.1.2
; Last updated: 2014-02-14


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

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
  file_name = "CAL_LID_L2_VFM-ValStage1-V3-02.2011-12-31T23-18-11ZD.hdf"

; Read the file.
  hdf4_file = addfile(file_name, "r") 

; Print information about the file to know what variables and attributes are 
; available for plotting.
;  print(hdf4_file)

; Users need to understand the layout of the Feature_Classification_Flag 
; dataset.
;
; The Feature_Classification_Flag values are stored as a sequence of 5515
;  element arrays (i.e., as an N x 5515 matrix, where N is the number of 
; separate records in the file). In this file, N is 4224.
;
;  Each array represents a 5 km "chunk" of data, 
; and each array element contains the feature classification information for a
;  single range resolution element in the Level 0 lidar data downlinked from 
; the satellite. As shown in the summary below, the vertical and horizontal 
; resolution of the CALIPSO data varies as a function of altitude above mean 
; sea level (see Hunt et al., 2009). 

; Here's the summary of number of prfoiles per 5 km.
; 
; 3 profiles for 20.2km (base) to 30.1km (top) @ 180m
; (index 1-165 / 55 samples per profile)
; 5 profiles for 8.2km (base) to 20.2km (top) @ 60m
; (index 166 - 1165 / 200 samples per profile)
; 15 profiles for -0.5km (base) to 8.2km (top) @ 30m 
; (index 1166 - 5515 / 290 samples per profile)
;
; 3 profiles mean horizontal resolution is 1667m because 3 * 1667m = 5km.
; 55 samples mean vertical resolution is 180m because 55 * 180m = 9.9km  = 
; 30.1km - 20.2km.
;
; 1.1132km equals to 0.01 degree difference.
; 111.32m equals to 0.001 degree difference.
; 
; Thus, we can ignore horizontal resolution for this global plot example.
;
; In summary, profile size determines horizontal resolution and sample size
; determines the vertical resolution.
;
; Each vertical feature mask record is a 16 bit integer.  See [2] for details.
; Bits | Description
; ----------------
; 1-3  | Feature Type
; 4-5  | Feature Type QA
; ...   |...
; 14-16 | Horizontal averaging

; In this example, we'll focus only on "Featrue type."
; 
; However, the resolution of the height will be different.
;
; Altitude Lidar data is in "metadta" [3] stored as HDF4 Vdata. 
; Lidar_Data_Altitudes has 583 records it does not match dataset size
; 565(=55+200+290).
; There are 5 below -0.5km and 30 above 30.1km.
;
; Therefore, we cannot not rely on the Vdata for altitude. NCL cannot read
; Vdata either, anyway.
;
; Instead, we should calculate altitude from the data specification.
;
; For each 5515 at a specific lat/lon, we can construct cloud bit vector over 
; altitude.
;
; For example, Feature_Classification_Flags[loc][55] means, 
; Longitude[loc] and altitude = 30.1km.
;
; For another example, Feature_Classification_Flags[loc][56] means, 
; Longitude[loc] + 1667m and altitude = 20.2km.
; 
; There are many possibilites to plot this data.
; Here, we'll pick a specific altitude and plot Feature Type on map.
  fcf = hdf4_file->Feature_Classification_Flags

; Pick the profile at 2500m (= -0.5km + 30m * 100) altitude.
  profile1 = fcf(:,1265)
  size = dimsizes(profile1)


; Select the first 1-3 bit for the feature type. See [4, 5] for dim_gbits.
  data = dim_gbits(profile1, 13, 3, 13, size(0))

  data@long_name = "Feature Type at altitude=2500m"
  lat = hdf4_file->Latitude(:,0)
  lon = hdf4_file->Longitude(:,0)

; Plot the data on world map first.

; Feature type has 8 possible values.
  levels = (/0, 1, 2, 3, 4, 5, 6, 7/)
  nlevels  = dimsizes(levels)
  wks = gsn_open_wks("png", file_name+".ncl") ; open workstation
  colormap = "WhViBlGrYeOrRe"
  gsn_define_colormap(wks,colormap)
  cmap = gsn_retrieve_colormap(wks)

; Get a nice span of colors through the current color map, but
; skip the first three colors (0-2).
  colors = span_color_indexes(levels,cmap(0:,:))

; Create a map plot for which to add color-coded markers.
  mpres                       = True

  mpres@gsnMaximize           = True   ; maximize size of plot in window
  mpres@gsnDraw               = False  ; turn off draw
  mpres@gsnFrame              = False  ; turn off page advance

  mpres@mpMinLatF             = min(lat)
  mpres@mpMaxLatF             = max(lat)
  mpres@mpMinLonF             = min(lon)
  mpres@mpMaxLonF             = max(lon)
  mpres@tiMainString          = file_name
  mpres@gsnLeftString = "FIELD:" + data@long_name 
  mpres@pmTickMarkDisplayMode = "Always"    ; Nicer map tickmarks

  map = gsn_csm_map(wks,mpres)

; Group the data values according to which range they fall
; in, and attach them to the map as a colored marker.
  mkres               = True
  mkres@gsMarkerIndex = 16        ; filled dot
  mkres@gsMarkerSizeF = 0.002
  markerid = new(size(0),graphic)

do i=0,size(0)-1
    mkres@gsMarkerColor = colors(data(i))
    markerid(i) = gsn_add_polymarker(wks,map,lon(i),lat(i),mkres)
end do

draw(map)   ; This will draw map and the attached markers

; Draw a labelbar
;----------------------------------------------------------------------
lbres                    = True
lbres@vpWidthF           = 0.80             ; width
lbres@vpHeightF          = 0.10             ; height
lbres@lbPerimOn          = False            ; Turn off perimeter.
lbres@lbOrientation      = "Horizontal"     ; Default is vertical.
lbres@lbFillColors       = colors           ; Colors for boxes.
lbres@lbMonoFillPattern  = True             ; Fill them all solid.
lbres@lbLabelFontHeightF = 0.012            ; label font height

labels = (/"invalid", "clear air", "cloud", "aerosol", "strato.", "surface", "subsurf.", "no signal"/)
gsn_labelbar_ndc (wks,nlevels,labels,0.1,0.23,lbres) 

frame(wks)

delete(wks)
delete(data)
delete(lat)
delete(lon)
delete(mpres)
delete(lbres)
delete(hdf4_file)

end
; References
;
; [1] http://www.ncl.ucar.edu/Applications/Scripts/polyg_17.ncl
; [2] http://www-calipso.larc.nasa.gov/resources/calipso_users_guide/data_summaries/vfm/index.php
; [3] http://www-calipso.larc.nasa.gov/resources/calipso_users_guide/data_summaries/vfm/index.php#heading03
; [4] https://www.ncl.ucar.edu/Document/Functions/Built-in/dim_gbits.shtml
; [5] http://www.ncl.ucar.edu/Applications/Scripts/hdf4eos_5.ncl

