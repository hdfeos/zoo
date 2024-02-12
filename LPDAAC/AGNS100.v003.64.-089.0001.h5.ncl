;
; This example code illustrates how to access and visualize LP DAAC ASTER
; GED HDF5 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Tested under: NCL 6.1.2
; Last updated: 2014-4-3

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  file_name = "AGNS100.v003.64.-089.0001.h5"

; Read file. 
  h5_file = addfile(file_name, "r") 

; Print metadata in the file.
  print(h5_file)

; You can select any dataset.
;  data = h5_file->/NDVI/Mean
;  data = h5_file->/Temperature/Mean

; Here, we select Emissivity to demonstrate subsetting.
  data_all = h5_file->/Emissivity/Mean

; See [1] for Fill value specification.
; h means short type [2].
  data_all@_FillValue = -9999h

; Subset for Band 10 (8.3 um) [1].
  data_s = data_all(1,:,:)
;  dataf = double(data_s)

; Apply scale factor [1]. 
  data = data_s * 0.001;

; Set lat/lon variables.
  lat =  h5_file->/Geolocation/Latitude
  lon =  h5_file->/Geolocation/Longitude

; Set CF attributes for plot.
  lat@units = "degrees_north"
  lon@units = "degrees_east"
  data@long_name = "Mean Emissivity for Band 10"
  data@units = "None"


; Associate data with geolocation variables.
  data@lat2d = lat
  data@lon2d = lon

  xwks = gsn_open_wks("png", file_name+".ncl") ; open workstation
  gsn_define_colormap(xwks,"amwg")

  res=True
  res@gsnMaximize=True   ;make plot large
  res@gsnPaperOrientation = "portrait"    ;force portrait orientation
  res@gsnSpreadColors=True    ; use the entire color spectrum
  res@tiMainString = file_name

  res@cnFillOn=True   ;enable contour fill
  res@cnLinesOn=False   ;turn off contour line
  res@cnLineLabelsOn =  False    ;turn off contour line labels
  res@lbOrientation="vertical" ; vertical labels
  res@cnFillMode="RasterFill"   ;faster
  res@trGridType="triangularmesh"
  res@lbLabelAutoStride= True

  ; The next 5 statements are for a zoomed image.
  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d)
  res@mpMaxLatF	= max(data@lat2d)
  res@mpMinLonF	= min(data@lon2d)
  res@mpMaxLonF	= max(data@lon2d)

  ; Don't advance frame yet [3].
  res@gsnFrame = False
  plot=gsn_csm_contour_map(xwks,data,res)

  ; Add description at the bottom of the figure.
  txres = True
  txres@txFontHeightF = 0.02
  gsn_text_ndc(xwks, data_all@Description, 0.5, 0.02, txres)

  ; Now advance frame.
  frame(xwks)

  delete(plot)
  delete(data)
  delete(res)
  delete(h5_file)
end

; References
;
; [1] https://lpdaac.usgs.gov/products/community_products_table/agns100
; [2] https://www.ncl.ucar.edu/Document/Manuals/Ref_Manual/NclDataTypes.shtml
; [3] http://www.ncl.ucar.edu/Applications/Scripts/text_2.ncl