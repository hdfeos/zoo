;
;  This example code illustrates how to access and visualize LaRC CERES 
; ISCCP D2like Day Aqua FM3 MODIS HDF4 file in NCL. 
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
; $ncl CER_ISCCP-D2like-Day_Aqua-FM3-MODIS_Edition3A_300300.201612.hdf.ncl
;
; Tested under: NCL 6.4.0
; Last updated: 2018-08-07

begin
  file_name = "CER_ISCCP-D2like-Day_Aqua-FM3-MODIS_Edition3A_300300.201612.hdf";

  hdf4_file=addfile(file_name, "r")
;  print(hdf4_file)


; Read data field.
  data=hdf4_file->Liquid_Log_Optical_Depth_Altocumulus_Monthly_Mean(0,:,:)

; Read lat/lon.
  colat=hdf4_file->Colatitude_Monthly_Mean(0,:,:)
  lon=hdf4_file->Longitude_Monthly_Mean(0,:,:)

; Adjust lat/lon to be in the valid range (-90 ~ 90 and -180 ~ 180).
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

