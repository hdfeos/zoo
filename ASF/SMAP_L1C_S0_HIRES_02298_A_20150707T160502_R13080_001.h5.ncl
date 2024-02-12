;
;   This example code illustrates how to access and visualize ASF SMAP
; L1C HDF5 file in NCL. 
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
; $ncl SMAP_L1C_S0_HIRES_02298_A_20150707T160502_R11850_001.h5.ncl
; Tested under: NCL 6.6.2
; Last updated: 2020-01-13

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
  file_name = "SMAP_L1C_S0_HIRES_02298_A_20150707T160502_R13080_001.h5"
  
; Without the following option, segmentation fault occurs in NCL 6.3.0.
; If you don't want this option, use 'ncl -f'.
;  setfileoption("h5", "FileStructure", "Advanced")

; Read file as an HDF5 file. 
  h5_file = addfile(file_name, "r") 

;  print(h5_file)

  data_raw = h5_file->cell_sigma0_hh_fore
  data = where(data_raw.gt.data_raw@valid_min .and. data_raw.lt.data_raw@valid_max, data_raw, data_raw@_FillValue)
  data@long_name = data_raw@long_name

;  printVarSummary(data)
  data@lat2d = h5_file->cell_lat
  data@lon2d = h5_file->cell_lon
  data@long_name = data_raw@long_name
  data@units = "None"
  
  wks = gsn_open_wks("png", file_name+".ncl") ; open workstation
  res=True
  res@gsnMaximize=True   ; make plot large
  res@gsnPaperOrientation = "portrait"    ; force portrait orientation
  res@gsnSpreadColors=True    ; use the entire color spectrum
  res@cnFillOn=True   ; enable contour fill
  res@cnLinesOn=False   ; turn off contour line
  res@cnLineLabelsOn =  False    ; turn off contour line labels
  res@cnFillMode="RasterFill"   ; faster
  res@lbLabelAutoStride= True
  res@lbOrientation="vertical" ; vertical labels
  res@trGridType = "TriangularMesh" 
  res@tiMainString = file_name
  res@gsnLeftStringFontHeightF = 12 ; make font smaller 
  res@gsnRightStringFontHeightF = 12 ; make font smaller   
  plot=gsn_csm_contour_map(wks,data,res)
end

; References
;
;  [1] http://www.ncl.ucar.edu/Applications/Scripts/polyg_17.ncl

