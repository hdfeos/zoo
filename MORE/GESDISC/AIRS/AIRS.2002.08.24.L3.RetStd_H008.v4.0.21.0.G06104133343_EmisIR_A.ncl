;This example code illustrates how to access and visualize GESDISC_AIRS Swath in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
eos_file=addfile("AIRS.2002.08.24.L3.RetStd_H008.v4.0.21.0.G06104133343.hdf.he2", "r")

EmisIR_A=eos_file->EmisIR_A_ascending(0,:,:)
EmisIR_A@lon2d=eos_file->Longitude_location
EmisIR_A@lat2d=eos_file->Latitude_location
EmisIR_A@_FillValue = -9999


EmisIR_A_1=eos_file->EmisIR_A_ascending(1,:,:)
EmisIR_A_1@lon2d=eos_file->Longitude_location
EmisIR_A_1@lat2d=eos_file->Latitude_location
EmisIR_A_1@_FillValue = -9999

EmisIR_A_2=eos_file->EmisIR_A_ascending(2,:,:)
EmisIR_A_2@lon2d=eos_file->Longitude_location
EmisIR_A_2@lat2d=eos_file->Latitude_location
EmisIR_A_2@_FillValue = -9999

EmisIR_A_3=eos_file->EmisIR_A_ascending(3,:,:)
EmisIR_A_3@lon2d=eos_file->Longitude_location
EmisIR_A_3@lat2d=eos_file->Latitude_location
EmisIR_A_3@_FillValue = -9999


xwks=gsn_open_wks("pdf","AIRS.2002.08.24.L3.RetStd_H008.v4.0.21.0.G06104133343_EmisIR_A")

setvalues NhlGetWorkspaceObjectId()
"wsMaximumSize" : 500000000
end setvalues

res=True
res@cnFillOn=True
res@cnLinesOn=False
res@cnMissingValFillPattern = 0
res@cnMissingValFillColor = 17

;res@sfXArray = eos_file->Longitude_L1B_AIRS_Cal_Subset
;res@sfYArray = eos_file->Latitude_L1B_AIRS_Cal_Subset

cmap = (/"(/1.00, 1.00, 1.00/)", "(/0.00, 0.00, 0.00/)", \
         "(/.560, .500, .700/)", "(/.300, .300, .700/)", \
         "(/.100, .100, .700/)", "(/.000, .100, .700/)", \
         "(/.000, .300, .700/)", "(/.000, .500, .500/)", \
         "(/.000, .700, .100/)", "(/.060, .680, .000/)", \
         "(/.550, .550, .000/)", "(/.570, .420, .000/)", \
         "(/.700, .285, .000/)", "(/.700, .180, .000/)", \
         "(/.870, .050, .000/)", "(/1.00, .000, .000/)", \
         "CadetBlue", "Ivory", "LimeGreen", "DarkSalmon"/)
gsn_define_colormap(xwks,cmap)

plot=gsn_csm_contour_map_ce(xwks,EmisIR_A,res)
plot=gsn_csm_contour_map_ce(xwks,EmisIR_A_1,res)
plot=gsn_csm_contour_map_ce(xwks,EmisIR_A_2,res)
plot=gsn_csm_contour_map_ce(xwks,EmisIR_A_3,res)

delete(plot)
delete(EmisIR_A)
delete(res)
end

