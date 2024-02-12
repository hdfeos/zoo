;
;  This example code illustrates how to access and visualize LaRC CATS HDF5 file
; in NCL.
;
;  If you have any questions, suggestions, comments on this example, please use
; the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage:save this script and run 
;
; $ncl CATS-ISS_L2O_D-M7.2-V2-01_05kmLay.2017-05-01T00-47-40T01-28-41UTC.hdf5.v.ncl
;
; Tested under: NCL 6.4.0
; Last updated: 2018-06-15


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
      print ("Error: span_color_indexes: cmap must be an n x 3 or n x 4 array of RGB or RGBA values, or a valid color map name")
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
  file_name = "CATS-ISS_L2O_D-M7.2-V2-01_05kmLay.2017-05-01T00-47-40T01-28-41UTC.hdf5"

; Read the file.
  hdf5_file = addfile(file_name, "r") 

; Print information about the file to know what variables and attributes are 
; available for plotting.
;  print(hdf5_file)

  fov = hdf5_file->Aerosol_Type_Fore_FOV
  size = dimsizes(fov)
;  print(size)

  data_raw = fov(:,0)

  
; Get the geolocation data.
  latitude = hdf5_file->CATS_Fore_FOV_Latitude
  lat = latitude(:,2)

  y_scale = 23

  data = new((/dimsizes(data_raw),y_scale/),short)
;  print(dimsizes(data))
  data@long_name = "/layer_descriptor/Aerosol_Type_Fore_FOV at Layer 0"  
  base_altitude = hdf5_file->Layer_Base_Altitude_Fore_FOV
  base_altitude@_FillValue = -999.99
;  print(base_altitude)

  ; Create altitude (y-axis) from -2.0 km to 20.0km.
  alt = fspan(-2.0,20.0, y_scale)
  inds = new(dimsizes(base_altitude), "integer")
  nbin = dimsizes(alt) - 1
;  print(nbin)
  do i=0,size(0)-1
    do  j=0,size(1)-1
      ii = inds@_FillValue
      x = base_altitude(i,j)
      if (.not.ismissing(x))
        do nb=0,nbin-1
          if (x.ge.alt(nb) .and. x.lt.alt(nb+1))
            ii = nb
          end if
        end do          
      end if
      inds(i,j) = ii                
    end do
  end do
  do i=0,size(0)-1
    do  j=0,size(1)-1
      if (.not.ismissing(inds(i,j)))
        data(i,inds(i,j)) = fov(i,j)
      end if
    end do
  end do
  alt@long_name = "Altitude (km)"
  alt@units     = "km"
  alt!0 = "alt"
  
; NCL can plot only monotonically increasing / decreasing area.
; Subset the region that lat is monotonically increasing or decreasing.
; increasing  
  lat2 = lat(0:1148)
; decreasing  
;  lat2 = lat(1149:)
  lat2!0 = "lat2"
  lat2@long_name = "Latitude"
  lat2@units = "degrees_north"
  data = where(ismissing(data),0h,data)
; increasing  
  data2 = data(0:1148,:)
; decreasing  
;   data2 = data(1149:,:)
  data2!0   = "lat2"
  data2!1   = "alt"
  data2&lat2 = lat2
  data2&alt = alt
;  print(lat2)
  levels = (/0, 1, 2, 3, 4, 5, 6, 7, 8/)
  nlevels  = dimsizes(levels)
  xwks = gsn_open_wks("png", file_name + ".v.ncl") ; open workstation
  colormap = "WhViBlGrYeOrRe"
  gsn_define_colormap(xwks,colormap)
  cmap = gsn_retrieve_colormap(xwks)  
  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True; make plot large
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn =  False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0; white color for missing values
  res@lbLabelAutoStride = True ; ensure no label overlap
  colors = span_color_indexes(levels,cmap(0:,:))  
  res@cnFillColors = colors
  res@tiMainString = file_name
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels = (/1,2,3,4,5,6,7,8/)
;  res@cnLevels = levels
  res@lbLabelAlignment     = "BoxCenters"
;   res@lbLabelStrings       = (/"invalid", "marine", "p. marine", "dust", "dust mixture", "clean/bg", "p. continental", "smoke", "volcanic"/)
; Plot is narrow. Use shortened label.    
  res@lbLabelStrings       = (/"in", "ma", "pm", "du", "dm", "cb", "pc", "sm", "vo"/)
  plot = gsn_csm_contour(xwks, transpose(data2),res)  
  
; Clean up resources.
  delete(plot)
  delete(xwks)
  delete(data)
  delete(res)
  delete(hdf5_file)
end
; References
;
; [1] http://www.ncl.ucar.edu/Applications/Scripts/polyg_17.ncl

