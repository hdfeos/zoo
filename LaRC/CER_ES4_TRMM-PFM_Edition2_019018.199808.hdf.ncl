;
;  This example code illustrates how to access and visualize LaRC CERES 
; ES4 TRMM PFM Edition2 HDF-EOS2 file in NCL. 
;
;  If you have any questions, suggestions, comments  on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage:save this script and run 
;
; $ncl CER_ES4_TRMM-PFM_Edition2_019018.199808.hdf.ncl
;
; Tested under: NCL 6.4.0
; Last updated: 2018-06-29

begin
  file_name = "CER_ES4_TRMM-PFM_Edition2_019018.199808.hdf";

; To read the file as an HDF-EOS2 files, the ".he2" is appended to the 
; file name argument. 
; For more information, consult section 4.3.2 of [1]. 
  eos_file=addfile(file_name + ".he2", "r")
;  print(eos_file)
; To read the field from an HDF-EOS2 file, the group name must be appended to
; the data field. For more information,read section 4.3.2 of [1].
;
; Read data field.
  data=eos_file->$"Longwave flux"$

; Set fill value and units.
; See "CERES Data Management System ES-4 Collection Guide" [2] details about unit.
;  data@_FillValue=3.4028235E38
;  data@unit = "Watts/Meter~S~2"
;  data@long_name = "Longwave flux"


  colat=eos_file->Colatitude
  lon=eos_file->Longitude
  
; Define new latitude and new longitude because colat range=[0,180] and
; lon range=[0,360]
  dimsize = dimsizes(data)
  numlat = dimsize(0) ; numlat = 180
  numlon = dimsize(1) ; numlon = 360
  
  nlat=new( (/numlat,numlon/), float)
  mlon=new( (/numlat,numlon/), float)
  
  do i = 0, numlat-1
    do j = 0, numlon-1
      nlat(i,j) = 90. - colat(i,j)
    end do
  end do

  do i = 0, numlat-1
    do j = 0, numlon-1
      mlon(i,j) = lon(i,j)
      if (mlon(i,j).gt.180)
        mlon(i,j) = mlon(i,j) - 360.
      end if
    end do
  end do
 
  nlat@units="degrees_north"
  mlon@units="degrees_east"

; This file contains coordinate variables that will not properly plot. 
; To properly display the data, the latitude/longitude must be remapped.
;  data!0="lat" 
;  data!1="lon"
   data@lat2d=nlat
   data@lon2d=mlon

  xwks=gsn_open_wks("png", file_name+".ncl") ; open workstation

  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@gsnMaximize=True; make plot large
  res@gsnPaperOrientation =	"portrait" ; force portrait orientation
  res@cnLinesOn=False ; turn off contour lines
  res@cnLineLabelsOn       =  False; turn off contour line labels
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbOrientation="vertical" ;vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0; white color for missing values
  res@gsnLeftStringFontHeightF = 11 ; make font smaller
  res@gsnRightStringFontHeightF = 11 ; make font smaller
  res@trGridType = "TriangularMesh"

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; choose colormap
  res@tiMainString = file_name; create title
  plot=gsn_csm_contour_map_ce(xwks,data,res) ; create plot
end

; References
;
; [1] http://hdfeos.org/software/ncl.php.
; [2] http://ceres.larc.nasa.gov/documents/collect_guide/pdf/ES4_CG_R1V1.pdf
