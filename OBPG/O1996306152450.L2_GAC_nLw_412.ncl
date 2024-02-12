;
;  This example code illustrates how to access and visualize OBPG OCTS HDF4 
; L2 file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please use
; the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Tested under: NCL 6.0.0
; Last updated: 2012-12-20

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
; Since the file is not HDF-EOS2, it is not necessary to append .he2
; For more information, consult section 4.3.2 of 
; http://hdfeos.org/software/ncl.php.
  file_name = "O1996306152450.L2_GAC.hdf"

; Read file. 
  eos_file=addfile(file_name, "r")

; Read the data field.
  data_pre=eos_file->nLw_412

; It is assumed users know how to obtain information such as _FillValue from 
; HDFView. For information about HDFView, visit 
; http://www.hdfgroup.org/hdf-java-html/hdfview/
  data_pre@_FillValue=0h
  data_pre@_FillValue=1h


; From the hdf file, we can find eos_file->nLw_412 is 16-bit integer 
; (type short)
; short2flt() will converts values of type short to values of type float 
; using the "scale" and "offset" attributes (if present). 
; See http://www.ncl.ucar.edu/Document/Functions/Contributed/short2flt.shtml
;
; short2flt() can handle the following scale and offset:
; scale: "SCALE", "Scale", "_scale", "scale_factor", "Scale_factor", "Slope", 
;        "slope"
; offset: "add_offset", "OFFSET", "Offset", "_offset", "Intercept", "intercept"
;  
; eos_file->nLw_412 has attributes: slope and intercept, those attributes can
; be handled by short2flt()
  data = short2flt(data_pre)

  lat=eos_file->latitude
  lon=eos_file->longitude

  dimsize = dimsizes(data)
  numlat = dimsize(0)
  numlon = dimsize(1)

; Define new latitude and longitude. We need to interpolate lat and lon to 
; match the size of data.
  nlat=new( (/numlat,numlon/), float)
  mlon=new( (/numlat,numlon/), float)

  numCol = eos_file@Number_of_Pixel_Control_Points

  valueInCell = eos_file->cntl_pt_cols
  step1 = valueInCell(2) - valueInCell(1) ;step1=8
  step2 = valueInCell(numCol-1) - valueInCell(numCol-2) ;step2=7


  do i = 0, numlat-1
    do j =0, numCol-1 ;numCol-1=50

                                ;when j = 0
      if(j.eq.0)
        nlat(i,j) = lat(i,j)
        mlon(i,j) = lon(i,j)
        continue
      end if

                                ;when j = 1, ..., numCol-2 ;numCol-2=49
      if((j.ge.1).and.(j.le.(numCol-2))) ;numCol-2=49
        count=step1*(j-1)+1 ;step1=8
        arr_fill=fspan(lat(i,(j-1)), lat(i, j), (step1+1)) ;step1=8
        nlat(i, count:count+(step1-1)) = (/ arr_fill(1:(step1)) /) ;step1=8
        arr_fill=fspan(lon(i,(j-1)), lon(i, j), (step1+1)) ;step1=8
        mlon(i, count:count+(step1-1)) = (/ arr_fill(1:(step1)) /) ;step1=8
        continue
      end if

                                ;when j = numCol-1
      if(j.eq.(numCol-1)) ;numCol-1=50
        count=step1*(j-1)+1 ;step1=8
        array_fill=fspan(lat(i,(j-1)), lat(i, j), (step2+1)) ;step2=7
        nlat(i, count:count+(step2-1)) = (/ array_fill(1:(step2)) /) ;step2=7
        array_fill=fspan(lon(i,(j-1)), lon(i, j), (step2+1)) ;step2=7
        mlon(i, count:count+(step2-1)) = (/ array_fill(1:(step2)) /) ;step2=7
        continue
      end if
      
    end do
  end do


  data@lat2d=nlat
  data@lon2d=mlon

; Set attributes for plot labels.
  data@long_name = data_pre@long_name
  data@units = data_pre@units

  xwks=gsn_open_wks("pdf", file_name) ; open workstation

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
  res@lbLabelAutoStride = True ; ensure no label overlap


  gsn_define_colormap(xwks,"BlAqGrYeOrReVi200") ; define colormap

; Please make sure that you have a .hluresfile in your home directory 
; so you don't get any PLCHHQ error messages.
; See: http://www.ncl.ucar.edu/Document/Graphics/hlures.shtml
  res@tiMainString =  file_name

  plot=gsn_csm_contour_map_ce(xwks,data,res) ; plot on world map first

  delete(plot) ; cleaning up resources used
  delete(nlat)
  delete(mlon)
  delete(xwks)
  delete(data)
  delete(res)
  delete(eos_file)
end