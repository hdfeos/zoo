;
;  This example code illustrates how to access and visualize LaRC MISR
; AM1 GRP ELLIPSOID GM HDF-EOS2 SOM Grid file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums).
;
;   If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage:
;
; $ncl MISR_AM1_GRP_ELLIPSOID_GM_P117_O058421_BA_F03_0024.hdf.ncl
;
; Tested under: NCL 6.4.0
; Last updated: 2018-08-16

begin

; Read file.
; To read HDF-EOS2 files, .he2 is appended to the argument. 
; For more information, consult section 4.3.2 of [1].
  file_name = "MISR_AM1_GRP_ELLIPSOID_GM_P117_O058421_BA_F03_0024.hdf"
  eos_file = addfile(file_name+".he2", "r") 

; The following statement will print the Grid attribute "Scale_factor_BlueBand"
;  as a global attribute.
;  print(eos_file);

; The geolocation values are stored in a secondary file.
; Read geolocation file.
  geo_file = addfile("MISR_AM1_AGP_P117_F01_24.hdf.he2", "r") 

; Read data field.
; NCL reads the data as integer.
  data3D_raw = eos_file->Blue_Radiance_RDQI_BlueBand

; We need to convert the data to unsigned because NCL reads as signed integer.
; The original type is "uint16".
  data3D = tounsigned(data3D_raw)

  dimsize = dimsizes(data3D)
  nblocks = dimsize(0) ; 180
  ysize = dimsize(1) ; 128
  xsize = dimsize(2) ; 512
 offset = 0

; Change the following parameters to test a small number of blocks since 
; processing all 180 blocks may take too long.
;
; For example, uncomment the following two lines to test block 50, 51, 52
; because the first 50 blocks are mostly fill values.
;
; nblocks = 3
; offset = 50


; We need to shift bits for RDQI to get blue band only. 
; See the page 84 of "MISR Data Products Specifications (rev. S)".
; The document is available at [2].
; NCL doesn't have bitshift operator so we divide the unsigned integer value
; by 4.
  data3Ds = data3D / 4;

; Filter out values (> 16376) used for "Flag Data".
; See Table 1.2 in "Level 1 Radiance Scaling and Conditioning
; Algorithm  Theoretical Basis" document [3].
  data3Ds = where(data3Ds.gt.16376, data3Ds@_FillValue, data3Ds);

; Convert 3-D data to 2-D data.
  data2D = new((/ysize, nblocks*xsize/), float)

  do k = 0, nblocks-1
    do i = 0, xsize-1
      do j = 0, ysize-1
            data2D(j, k*xsize+i) = tofloat(data3Ds(k+offset,j,i))
      end do
    end do
  end do


; Convert 3D lat/lon to 2D lat/lon.
  lat2D = new((/ysize, nblocks*xsize/), float)
  lon2D = new((/ysize, nblocks*xsize/), float)
  lat3D = geo_file->GeoLatitude_Standard
  lon3D = geo_file->GeoLongitude_Standard

  do k = 0, nblocks-1
    do i = 0, xsize-1
      do j = 0, ysize-1
        lat2D(j, k*xsize+i) = (/lat3D(k+offset,j,i)/)
      end do
    end do
  end do
  do k = 0, nblocks-1
    do i = 0, xsize-1
      do j = 0, ysize-1
        lon2D(j, k*xsize+i) = (/lon3D(k+offset,j,i)/)
      end do
    end do
  end do
  
  data2D@lat2d = lat2D
  data2D@lon2d = lon2D
  data2D = data2D * stringtofloat(eos_file@Scale_factor_BlueBand)

; See NCL function code [4] and equations [5] pages on how to do subscripts, 
; superscripts, and greek characters.
;
; A number after the B or S indicates the level of the sub/superscript
; An "N" returns you back to "normal" level.
  data2D@units = "Wm~S~-2~N~sr~S~-1~N~" + "~F8~m~N~" + "~F21~m~S~-1~N~"
  data2D@long_name = "Blue_Radiance"
  
  xwks = gsn_open_wks("png", file_name+".ncl") 

  setvalues NhlGetWorkspaceObjectId() ; make maximum filesize larger
  "wsMaximumSize": 2000000000
  end setvalues

  res = True ; plot mods desired
  res@cnFillOn = True ; enable contour fill
  res@gsnMaximize = True; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn = False ; turn off contour lines
  res@cnLineLabelsOn = False; turn off contour line labels
  res@gsnSpreadColors = True ; use the entire color spectrum
  res@cnFillMode = "RasterFill" ; faster
  res@lbOrientation = "vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor = 0 ; white color for missing values
  res@lbLabelAutoStride = True ; ensure no label overlap
; Without the following statement, it will take too long and generate a graph
; that is cut by half in some blocks.
  res@trGridType = "TriangularMesh" 
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

; Create title.
  res@tiMainString=file_name
;  res@gsnLeftString=data2D@long_name
;  res@gsnRightString = data2D@unit

  res@gsnLeftStringFontHeightF = 9 ; make text smaller
  res@gsnRightStringFontHeightF = 9

; Set limits of map, based on the min/max of the dataset latitude/longitude.
  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data2D@lat2d) 
  res@mpMaxLatF	= max(data2D@lat2d)  
  res@mpMinLonF	= min(data2D@lon2d) 
  res@mpMaxLonF	= max(data2D@lon2d) 

  plot=gsn_csm_contour_map(xwks,data2D,res) 
end

; Reference
;
; [1] http://hdfeos.org/software/ncl.php
; [2] https://asdc.larc.nasa.gov/documents/misr/DPS_v50_RevS.pdf
; [3] https://eospso.gsfc.nasa.gov/atbd-category/45
; [4] http://www.ncl.ucar.edu/Applications/fcodes.shtml
; [5] http://www.ncl.ucar.edu/Applications/eqn.shtml
