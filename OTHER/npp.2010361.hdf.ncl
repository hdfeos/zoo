;  This example code illustrates how to access and visualize Ocean Productivity
;  net primary production (npp) HDF4 file in NCL.
;
;  If you have any questions, suggestions, comments on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums).
;
;   If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;

; Tested under: NCL 6.0.0
; Last updated: 2011-11-17

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  file_name= "npp.2010361.hdf"

  hdf_file=addfile(file_name, "r") ; Open file.
  print(hdf_file)                  ; Print file info.
  data_raw = hdf_file->npp         ; Read dataset.
  printVarSummary(data_raw)        ; Print variable info.

  data_raw@_FillValue = data_raw@Hole_Value


; See [1] for the meaningful description of data set.
  data_raw@long_name = data_raw@hdf_name +  " (" + hdf_file@Start_Time_String + "  - " +  hdf_file@Stop_Time_String + ")"
  data_raw@units = data_raw@Units

; The max value goes up to 13K. Limit the value to get a good plot like [2].
  data_raw = where(data_raw .gt. 1000, 1000, data_raw)

; Set lat / lon variable based on FAQ [3].
  nlat = 2160
  nlon = 4320
  lat = 90.0 - (180.0/nlat)*(ispan(0, nlat-1, 1) + 0.5) 
  lon = -180.0 + (360.0/nlon)*(ispan(0, nlon-1, 1) + 0.5)
  lat@units = "degrees_north"
  lon@units = "degrees_east"

  data_raw!0 = "lat"
  data_raw!1 = "lon"

  data_raw&lat = lat
  data_raw&lon = lon

  xwks=gsn_open_wks("pdf", file_name+".ncl") ; open workstation 

  setvalues NhlGetWorkspaceObjectId() ; make maximum filesize larger
  "wsMaximumSize" : 200000000
  end setvalues

  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@cnLinesOn=False ; turn off contour lines
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbLabelAutoStride=True ; ensure labels do not overlap
  res@lbOrientation = "vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0; white color for missing values

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

; You should also make sure you have a .hluresfile in your home directory 
; so you don't get any PLCHHQ error messages [4].
  res@tiMainString = file_name 

  plot=gsn_csm_contour_map_ce(xwks,data_raw,res) 

  delete(plot) ; cleaning up resources used
  delete(res)
  delete(xwks)
  delete(lat)
  delete(lon)
  delete(data_raw)
  delete(hdf_file)
end

; References
; [1] http://orca.science.oregonstate.edu/2160.by.4320.8day.hdf.vgpm.m.chl.m.sst4.php
; [2] http://www.science.oregonstate.edu/ocean.productivity/standard.product.php
; [3] http://orca.science.oregonstate.edu/faq01.php
; [4] http://www.ncl.ucar.edu/Document/Graphics/hlures.shtml
