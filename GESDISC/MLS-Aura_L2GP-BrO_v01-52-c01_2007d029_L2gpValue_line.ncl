;This example code illustrates how to access and visualize HDF-EOS5 MLS L2GP Swath file in NCL. 
;If you have any questions, suggestions, comments on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; This is an example of a 2-D grid file data field.
; It is assumed users know how to obtain information such as _FillValue from HDFView.
; For information about HDFView, visit http://www.hdfgroup.org/hdf-java-html/hdfview/.

begin
eos_file=addfile("MLS-Aura_L2GP-BrO_v01-52-c01_2007d029.he5", "r") ; Read file. 
;To read HDF-EOS5 files, .he5 is appended to the argument. 
;For more information, consult section 4.3.2 of http://hdfeos.org/software/ncl.php.

data2D=eos_file->L2gpValue_BrO
data=data2D(399,:)

pressure=eos_file->Pressure_BrO
time=eos_file->Time_BrO

; Create an "elapsed time" variable (International Atomic Time)
telapse=(time-time(0))/60
telapse@long_name="Elapsed Time (minutes)"
telapse@units    = "minutes since "+time(0)

xwks   = gsn_open_wks ("pdf","MLS-Aura_L2GP-BrO_v01-52-c01_2007d029_1lvlTime.ncl")    ; open workstation
gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")

res=True
res@gsnMaximize=True   ;make plot large
res@gsnPaperOrientation = "portrait"    ;force portrait orientation
res@lbOrientation        = "Vertical"
res@trYReverse           = True               ; reverse y-axis

res@tiMainString = "MLS-Aura_L2GP-BrO_v01-52-c01_2007d029.he5"
res@gsnLeftString="L2gpValue at Time=" +telapse(399)+"minutes" ; create left text
res@gsnRightString = "Units: " + data2D@units
res@tiXAxisString        = "Pressure (hPa)"

;about gsn_csm_xy(), see http://www.ncl.ucar.edu/Document/Graphics/Interfaces/gsn_csm_xy.shtml
plot=gsn_csm_xy(xwks,pressure,data,res) ; plot on world map first

delete(plot)
delete(data)
delete(res)
delete(eos_file)
end
