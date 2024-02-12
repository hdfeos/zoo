;
;  This example code illustrates how to access and visualize LaRC MISR L1B2 
; SOM Grid file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums).
;
;   If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

; Set file name. The "P052" in file name indicates the MISR path [1].
  file_name = "MISR_AM1_GRP_TERRAIN_GM_P052_O000997_AA_F03_0024.hdf"

; To read the file as an HDF-EOS2 file, .he2 is appended to the argument. 
; For more information, consult the section 4.3.2 of [2].
  eos_file = addfile(file_name+".he2", "r") 

; Check available datasets and attributes in the file.
; The following statement will print the Grid attribute "Scale_factor_BlueBand"
; as a global attribute.
  print(eos_file);

; Read data field.
; NCL reads the data as integer.
  data3D_raw = eos_file->Blue_Radiance_RDQI_BlueBand

; We need to convert the data to unsigned because NCL reads as signed integer.
; The original type is "uint16".
  data3D = tounsigned(data3D_raw)

  dimsize = dimsizes(data3D)
  nblocks = dimsize(0) ; 180 blocks
  ysize = dimsize(1)   ; 512
  xsize = dimsize(2)   ; 2048 

; We need to shift RDQI bits to get blue band only. 
; See the page 105 of "MISR Data Products Specifications (rev. M)".
; The document is available at [3].
; NCL doesn't have bitshift operator so we divide the unsigned integer value
; by 4.
  data3Ds = data3D / 4;

; Filter out values (> 16376) used for "Flag Data".
; See Table 6-23: Terrain-projected TOA Radiance Parameter Fill Values
; in  "Data Products Specifications (rev. M)" [3].
  data3Ds = where(data3Ds.gt.16376, data3Ds@_FillValue, data3Ds);

  data2D = new((/ysize, xsize/), float)

; Subset data. NCL uses 0-based indexing.
  data2D = data3Ds(49,:,:) 

; Apply scale factor.
  data2D = data2D * stringtofloat(eos_file@Scale_factor_BlueBand)

  nlon=ysize
  nlat=xsize

; The file contains SOM projection. We need to use eos2dump to generate lat 
; and lon. That is, 
; 
; $eos2dump -c1 MISR_AM1_GRP_TERRAIN_GM_P052_O000997_AA_F03_0024.hdf BlueBand 50 > lat_MISR_AM1_GRP_TERRAIN_GM_P052_O000997_AA_F03_0024.output
;
; $eos2dump -c2 MISR_AM1_GRP_TERRAIN_GM_P052_O000997_AA_F03_0024.hdf BlueBand 50 > lon_MISR_AM1_GRP_TERRAIN_GM_P052_O000997_AA_F03_0024.output
;
;
; For information on how to obtain the lat/lon data, check out [4]. 

  data2D@lat2d=asciiread("lat_MISR_AM1_GRP_TERRAIN_GM_P052_O000997_AA_F03_0024.output",(/nlon,nlat/),"float")
  data2D@lon2d=asciiread("lon_MISR_AM1_GRP_TERRAIN_GM_P052_O000997_AA_F03_0024.output",(/nlon,nlat/),"float")

  xwks=gsn_open_wks("png", file_name+".ncl") ; open workstation
  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@gsnMaximize=True; make plot large
  res@gsnPaperOrientation ="portrait" 
  res@cnLinesOn=False ; turn off contour lines
  res@cnLineLabelsOn = False; turn off contour line labels
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbOrientation="vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0; white color for missing values
  res@lbLabelAutoStride = True ; ensure no label overlap

; Define colormap
  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") 

  res@tiMainString=file_name ; create title
  res@mpLimitMode = "LatLon"

 ; Set limits of map, based on the min/max of the dataset latitude/longitude
  res@mpMinLatF	= min(data2D@lat2d)
  res@mpMaxLatF	= max(data2D@lat2d)  
  res@mpMinLonF	= min(data2D@lon2d) 
  res@mpMaxLonF	= max(data2D@lon2d) 

  res@gsnCenterString="Blue_Radiance at SOMBlockDim=50"
  res@gsnRightString = "Wm~S~-2~N~sr~S~-1~N~" + "~F8~m~N~" + "~F21~m~S~-1~N~"

  plot=gsn_csm_contour_map_ce(xwks,data2D,res)

 ; Clean up resources
  delete(plot)
  delete(xwks)
  delete(data3D)
  delete(data3Ds)
  delete(data2D)
  delete(res)

end

; References
;
; [1] https://l0dup05.larc.nasa.gov/MISR_BROWSE/path
; [2] http://hdfeos.org/software/ncl.php
; [3] https://asdc.larc.nasa.gov/documents/misr/DPS_v33_RevM.pdf
; [4] http://hdfeos.org/zoo/note_non_geographic.php