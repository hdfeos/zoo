;
;  This example code illustrates how to access and visualize LaRC CERES AVG
; Aqua FM3 MODIS Edition2B HDF4 grid file in NCL.
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
; $ncl CER_AVG_Aqua-FM3-MODIS_Edition2B_007005.200510.hdf.ncl
;
; Tested under: NCL 6.4.0
; Last updated: 2018-06-22

begin
; Read file.
  file_name="CER_AVG_Aqua-FM3-MODIS_Edition2B_007005.200510.hdf"
  hdf_file=addfile(file_name, "r")

; List file content.
; print(hdf_file) 

  data = hdf_file->LW_TOA_Clear_Sky__0(1,0,:,:)
  
; print(data)
; The shape of data is 4 dimension with the following dimension order:
; [Stats | 2] x [Monthly_Hourly_Avgs | 8] x [1_0_deg_regional_colat_zones | 180]
;  x [1_0_deg_regional_long_zones | 360]

  colat = hdf_file->Colatitude__0
  lon = hdf_file->Longitude__0

  dimsize = dimsizes(data)
  numlat = dimsize(0) ; numlat = 180
  numlon = dimsize(1) ; numlon = 360

; define new latitude and new longitude
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

  data@lat2d=nlat ; lat2d is reserved name, so do not need to define it
  data@lon2d=mlon ; lon2d is reserved name, so do not need to define it
  data@long_name = data@hdf_name
  
  xwks=gsn_open_wks("png", file_name+".ncl") ; open workstation

  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@gsnMaximize=True; make plot large
  res@gsnPaperOrientation = "portrait" ; force portrait orientation
  res@cnLinesOn=False ; turn off contour lines
  res@cnLineLabelsOn =  False; turn off contour line labels
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbOrientation = "vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0; white color for missing values
  res@lbLabelAutoStride=True ; ensure labels do not overlap

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  res@tiMainString = file_name
  plot=gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first
end
