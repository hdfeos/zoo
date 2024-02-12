; This example code illustrates how to access and visualize GESDISC_TRMM file in NCL. 
; If you have any questions, suggestions, comments  on this example, please use the 
; DF-EOS Forum (http://hdfeos.org/forums). If you would like to see an  example of 
; any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS 
; Comprehensive Examples page (http://hdfeos.org/zoo), feel free to contact us at 
; eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; This is an example of a 2-D swath file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

  load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

  begin

; Since the file is not HDF-EOS2, it is not necessary to append .he2.
  hdf4_file=addfile("2B31_CSI.990911.10296.KORA.6.HDF", "r") ; Read file. 
; Since the file is not HDF-EOS2, it is not necessary to append the group name.
  data=hdf4_file->dHat

; We cannot use short2flt() here since we need to divide the value with the scale factor.
  dataf = int2flt(data)

; Apply scale factor according to [1].
  datas = (data@add_offset + dataf) / data@scale_factor

  datas@lon2d=hdf4_file->geolocation(:,:,1); associate longitude and latitude
  datas@lat2d=hdf4_file->geolocation(:,:,0); here, both longitude and latitude are stored in the same data field, but with different subsets.
  datas@unit="mm"; according to [1]

  xwks=gsn_open_wks("pdf","2B31_CSI.990911.10296.KORA.6_dHat") ; open workstation

  res=True ; plot mods desired
  res@cnFillOn=True ; enable contour fill
  res@gsnMaximize=True; make plot large
  res@gsnPaperOrientation =	"portrait" ; force portrait orientation
  res@cnLinesOn=False ; turn off contour lines
  res@cnLineLabelsOn       =  False; turn off contour line labels
  res@gsnSpreadColors=True ; use the entire color spectrum
  res@cnFillMode="RasterFill" ; faster
  res@lbOrientation="vertical" ; vertical labels
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor=0; white color for missing values

  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

  res@tiMainString="2B31_CSI.990911.10296.KORA.6.HDF" ; create title
  plot=new(2, "graphic") ; allocate plot

  res@gsnCenterString="dHat" ; create center text
  plot(0)=gsn_csm_contour_map_ce(xwks,datas,res)
  delete(res@tiMainString) ; delete title for subsequent plots

  res@mpLimitMode         = "LatLon"
  res@mpMinLatF	= min(datas@lat2d) ; Set limits of map, based on the min/max of the dataset latitude/longitude
  res@mpMaxLatF	= max(datas@lat2d) ; 
  res@mpMinLonF	= min(datas@lon2d) ;
  res@mpMaxLonF	= max(datas@lon2d) ;

  res@gsnCenterString="dHat"
  plot(1)=gsn_csm_contour_map_ce(xwks,datas,res)

; cleaning up resources used
  delete(plot) 
  delete(data)
  delete(xwks)
  delete(res)
  delete(hdf4_file)

end

; Reference
; [1] http://disc.sci.gsfc.nasa.gov/precipitation/documentation/TRMM_README/TRMM_2B31_readme.shtml