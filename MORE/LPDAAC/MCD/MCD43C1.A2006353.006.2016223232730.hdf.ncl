;
;  This example code illustrates how to access and visualize a LP DAAC
; MCD43C1 HDF-EOS2 file in NCL.
;
;  If you have any questions, suggestions, comments on this example, please use
; the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage: save this script and run
;
; $ncl MCD43C1.A2006353.006.2016223232730.hdf.ncl
;
; Tested under: NCL 6.6.2
; Last updated: 2021-10-07

begin
file_name = "MCD43C1.A2006353.006.2016223232730.hdf"

;To read HDF-EOS2 files, .he2 is appended to the argument.
; For more information, consult section 4.3.2 of
; http://hdfeos.org/software/ncl.php.
eos_file = addfile(file_name+".he2", "r") ; Read file. 

; print(eos_file)

data_unscaled = eos_file->BRDF_Albedo_Parameter3_Band4_MCD_CMG_BRDF_0_05Deg
data = short2flt(data_unscaled)
xwks = gsn_open_wks("png", file_name+".ncl")

; Make maximum workspace reallocation size larger than 100000000.
setvalues NhlGetWorkspaceObjectId() 
"wsMaximumSize" : 200000000
end setvalues

res = True
res@cnFillOn = True
res@cnLinesOn = False
res@gsnSpreadColors = True
res@cnFillMode = "RasterFill"
res@lbLabelAutoStride = True
res@lbOrientation = "vertical"
res@cnMissingValFillPattern = 0
res@cnMissingValFillColor = 0
res@tiMainString = file_name

gsn_define_colormap(xwks,"BlAqGrYeOrReVi200")
plot = gsn_csm_contour_map_ce(xwks,data,res)

end
