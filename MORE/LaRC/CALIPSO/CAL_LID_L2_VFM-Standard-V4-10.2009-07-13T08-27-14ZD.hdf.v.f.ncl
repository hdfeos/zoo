; 
;  This example code illustrates how to access and visualize LaRC CALIPSO
; LIDAR L2 Virtical Feature Mask (VFM) HDF4 file in NCL. 
;
;  If you have any questions, suggestions, comments  on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; $ncl CAL_LID_L2_VFM-Standard-V4-10.2009-07-13T08-27-14ZD.hdf.v.f.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2021-04-06

; NOTE: NCL 6.6.2 will report the following error.
;
; fatal:HDF: An error occurred while attempting to read variable
; (Feature_Classification_Flags) from file
; (CAL_LID_L2_VFM-Standard-V4-10.2009-07-13T08-27-14ZD.hdf)
;
; However, it still can generate a plot.

begin
  file_name = "CAL_LID_L2_VFM-Standard-V4-10.2009-07-13T08-27-14ZD.hdf"
  
; Read file. 
  hdf_file = addfile(file_name, "r") 

; The following line prints all variables and attributes.
;  print(hdf_file)

; Users need to understand the layout of the Feature_Classification_Flag 
; dataset.
;
; The Feature_Classification_Flag values are stored as a sequence of 5515
;  element arrays (i.e., as an N x 5515 matrix, where N is the number of 
; separate records in the file). In this file, N is 4224.
;
;  Each array represents a 5 km "chunk" of data, 
; and each array element contains the feature classification information for a
; single range resolution element in the Level 0 lidar data downlinked from 
; the satellite. As shown in the summary below, the vertical and horizontal 
; resolution of the CALIPSO data varies as a function of altitude above mean 
; sea level (see Hunt et al., 2009). 
;
; Here's the summary of number of profiles per 5 km.
; 
; 3 profiles for 20.2km (base) to 30.1km (top) @ 180m
; (index 1-165 / 55 samples per profile)
;
; 5 profiles for 8.2km (base) to 20.2km (top) @ 60m
; (index 166 - 1165 / 200 samples per profile)
;
; 15 profiles for -0.5km (base) to 8.2km (top) @ 30m 
; (index 1166 - 5515 / 290 samples per profile)
;
; 3 profiles mean horizontal resolution is 1667m because 3 * 1667m = 5km.
; 55 samples mean vertical resolution is 180m because 55 * 180m = 9.9km (= 
; 30.1km - 20.2km).
;
; In short, profile size determines horizontal resolution and sample size
; determines the vertical resolution.
;
; Each record is an unsigned 16 bit integer.  See [1] for details.
; Bits | Description
; ----------------
; 1-3  | Feature Type
; 4-5  | Feature Type QA
; ...  | ...
; 10-12| If feature type = aerosol, bits 10-12 will specify the aerosol type
; ...  | ...
; 14-16| Horizontal averaging
;
;
; In this example, we'll focus on Featrue Type (bits 1-3) and aerosol type
; (bits 10-12).
;
; There are many possibilites to plot this data.
;
; Here, we'll subset -05km to 8.2km (e.g., 1165:5514) 
; over latitude approx. 40N to 62N (e.g., 3500:3999)
; and plot altitude vs. latitude.
  fcf = hdf_file->Feature_Classification_Flags
;  printVarSummary(fcf)
; Subset dataset that latitude value increases monotonically.
; Monotonicity is required by NCL.
  lat = hdf_file->Latitude(470:695,0)

; You can visualize other blocks by changing subset parameters.
;  profile = fcf(470:695, 0:164) ; 20.2km to 30.1km
;  profile = fcf(470:695,165:1164) ; 8.2km to 20.2km
  profile = fcf(470:695,1165:5514) ; -0.5km to 8.2km


  size = dimsizes(profile)


; Select the 1-3 bit for the feature type. See [2, 3] for dim_gbits.
  data2d = dim_gbits(profile, 13, 3, 13, size(1))
 
; Reshape 2-D data to 3-D for n profiles * y samples. 
; You can visualize other blocks by changing subset parameters.
;  data3d = reshape(data2d, (/size(0),  3, 55/))
;  data3d = reshape(data2d, (/size(0),  5, 200/))
  data3d = reshape(data2d, (/size(0), 15, 290/))
;  data3d = reshape(data2d, (/size(0), 290, 15/))
; printVarSummary(data3d)
; Subset horizontally. Variation along longitude (i.e., profile) is very 
; small. We'll just pick the first location from each profile.
  data_raw = data3d(:,0,:)
;  data_raw = data3d(:,:,0)

;0 = invalid
;1 = clear air
;2 = cloud
;3 = aerosol
;4 = stratospheric feature
;5 = surface
;6 = subsurface
;7 = no signal (totally attenuated)

  levels = (/0.5,1.5,2.5,3.5,4.5,5.5,6.5/)  

  xwks = gsn_open_wks("png", file_name + ".v.f.ncl") ; open workstation
  colormap= (/"white","black","orange","green","brown","blue","pink","grey"/)
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
  res@cnFillColors = cmap  
  res@tiMainString = file_name
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels = levels; (/0.5,1.5,2.5,3.5,4.5,5.5,6.5/) 
  res@lbLabelAlignment     = "BoxCenters"
  res@lbLabelStrings       = (/"invalid","clear air","cloud","aerosol","stratospheric feature","surface","subsurface","no signal"/)  
  res@lbOrientation =   "vertical" 
; Create altitude dataset manually like NCL CALIPSO example [4].
; You can visualize other blocks by changing subset parameters.
;
;  hgt = ispan(20200, 30020, 180)
;  hgt = ispan(8200, 20140, 60)
  hgti = ispan(-500, 8170, 30)
;  hgti = ispan(8170, -500, -30)
  hgt = tofloat(hgti) / 1000.0
  hgt = hgt(::-1)
  hgt@long_name = "Altitude (km)"
  hgt@units     = "km"
  hgt!0 = "hgt"

  lat!0 = "lat"
  lat@long_name = "Latitude"
  lat@units = "degrees_north"
  data = todouble(data_raw)
  data@long_name = "Feature Type (Bits 1-3) in Feature Classification Flag"
  data!0   = "lat"
  data!1   = "hgt"
  data&lat =  lat
  data&hgt = hgt
;  printVarSummary(data)

; Transpose data so that x-axis becomes latitude and y-axis becomes altitude.
  plot = gsn_csm_contour(xwks, transpose(data(::-1,::-1)),res) 
end

; References
;
; [1] http://www-calipso.larc.nasa.gov/resources/calipso_users_guide/data_summaries/vfm/index.php
; [2] https://www.ncl.ucar.edu/Document/Functions/Built-in/dim_gbits.shtml
; [3] http://www.ncl.ucar.edu/Applications/Scripts/hdf4eos_5.ncl
; [4] http://www.ncl.ucar.edu/Applications/Scripts/calipso_3.ncl