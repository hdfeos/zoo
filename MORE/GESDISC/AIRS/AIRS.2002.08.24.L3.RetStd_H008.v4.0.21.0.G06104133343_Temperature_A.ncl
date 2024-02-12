;This example code illustrates how to access and visualize GESDISC_AIRS Swath in NCL. 
;If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
;If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
;feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).


load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
eos_file=addfile("AIRS.2002.08.24.L3.RetStd_H008.v4.0.21.0.G06104133343.hdf.he2", "r")

Temperature_A=eos_file->Temperature_A_ascending(0,:,:)
Temperature_A@lon2d=eos_file->Longitude_location
Temperature_A@lat2d=eos_file->Latitude_location
Temperature_A@unit="Temperature unit Kelvin" ; the 'unit' attribute is not found in the HDF file and assumed to be Kelvin

Temperature_A_1=eos_file->Temperature_A_ascending(1,:,:)
Temperature_A_1@lon2d=eos_file->Longitude_location
Temperature_A_1@lat2d=eos_file->Latitude_location
Temperature_A_1@unit="Temperature unit Kelvin"


Temperature_A_2=eos_file->Temperature_A_ascending(2,:,:)
Temperature_A_2@lon2d=eos_file->Longitude_location
Temperature_A_2@lat2d=eos_file->Latitude_location
Temperature_A_2@unit="Temperature unit Kelvin"

Temperature_A_3=eos_file->Temperature_A_ascending(3,:,:)
Temperature_A_3@lon2d=eos_file->Longitude_location
Temperature_A_3@lat2d=eos_file->Latitude_location
Temperature_A_3@unit="Temperature unit Kelvin"

Temperature_A_4=eos_file->Temperature_A_ascending(4,:,:)
Temperature_A_4@lon2d=eos_file->Longitude_location
Temperature_A_4@lat2d=eos_file->Latitude_location
Temperature_A_4@unit="Temperature unit Kelvin"

Temperature_A_5=eos_file->Temperature_A_ascending(5,:,:)
Temperature_A_5@lon2d=eos_file->Longitude_location
Temperature_A_5@lat2d=eos_file->Latitude_location
Temperature_A_5@unit="Temperature unit Kelvin"

Temperature_A_6=eos_file->Temperature_A_ascending(6,:,:)
Temperature_A_6@lon2d=eos_file->Longitude_location
Temperature_A_6@lat2d=eos_file->Latitude_location
Temperature_A_6@unit="Temperature unit Kelvin"

Temperature_A_7=eos_file->Temperature_A_ascending(7,:,:)
Temperature_A_7@lon2d=eos_file->Longitude_location
Temperature_A_7@lat2d=eos_file->Latitude_location
Temperature_A_7@unit="Temperature unit Kelvin"

Temperature_A_8=eos_file->Temperature_A_ascending(8,:,:)
Temperature_A_8@lon2d=eos_file->Longitude_location
Temperature_A_8@lat2d=eos_file->Latitude_location
Temperature_A_8@unit="Temperature unit Kelvin"

Temperature_A_9=eos_file->Temperature_A_ascending(9,:,:)
Temperature_A_9@lon2d=eos_file->Longitude_location
Temperature_A_9@lat2d=eos_file->Latitude_location
Temperature_A_9@unit="Temperature unit Kelvin"

Temperature_A_10=eos_file->Temperature_A_ascending(10,:,:)
Temperature_A_10@lon2d=eos_file->Longitude_location
Temperature_A_10@lat2d=eos_file->Latitude_location
Temperature_A_10@unit="Temperature unit Kelvin"

Temperature_A_11=eos_file->Temperature_A_ascending(11,:,:)
Temperature_A_11@lon2d=eos_file->Longitude_location
Temperature_A_11@lat2d=eos_file->Latitude_location
Temperature_A_11@unit="Temperature unit Kelvin"

Temperature_A_12=eos_file->Temperature_A_ascending(12,:,:)
Temperature_A_12@lon2d=eos_file->Longitude_location
Temperature_A_12@lat2d=eos_file->Latitude_location
Temperature_A_12@unit="Temperature unit Kelvin"

Temperature_A_13=eos_file->Temperature_A_ascending(13,:,:)
Temperature_A_13@lon2d=eos_file->Longitude_location
Temperature_A_13@lat2d=eos_file->Latitude_location
Temperature_A_13@unit="Temperature unit Kelvin"

Temperature_A_14=eos_file->Temperature_A_ascending(14,:,:)
Temperature_A_14@lon2d=eos_file->Longitude_location
Temperature_A_14@lat2d=eos_file->Latitude_location
Temperature_A_14@unit="Temperature unit Kelvin"

Temperature_A_15=eos_file->Temperature_A_ascending(15,:,:)
Temperature_A_15@lon2d=eos_file->Longitude_location
Temperature_A_15@lat2d=eos_file->Latitude_location
Temperature_A_15@unit="Temperature unit Kelvin"

Temperature_A_16=eos_file->Temperature_A_ascending(16,:,:)
Temperature_A_16@lon2d=eos_file->Longitude_location
Temperature_A_16@lat2d=eos_file->Latitude_location
Temperature_A_16@unit="Temperature unit Kelvin"

Temperature_A_17=eos_file->Temperature_A_ascending(17,:,:)
Temperature_A_17@lon2d=eos_file->Longitude_location
Temperature_A_17@lat2d=eos_file->Latitude_location
Temperature_A_17@unit="Temperature unit Kelvin"

Temperature_A_18=eos_file->Temperature_A_ascending(18,:,:)
Temperature_A_18@lon2d=eos_file->Longitude_location
Temperature_A_18@lat2d=eos_file->Latitude_location
Temperature_A_18@unit="Temperature unit Kelvin"

Temperature_A_19=eos_file->Temperature_A_ascending(19,:,:)
Temperature_A_19@lon2d=eos_file->Longitude_location
Temperature_A_19@lat2d=eos_file->Latitude_location
Temperature_A_19@unit="Temperature unit Kelvin"

Temperature_A_20=eos_file->Temperature_A_ascending(20,:,:)
Temperature_A_20@lon2d=eos_file->Longitude_location
Temperature_A_20@lat2d=eos_file->Latitude_location
Temperature_A_20@unit="Temperature unit Kelvin"

Temperature_A_21=eos_file->Temperature_A_ascending(21,:,:)
Temperature_A_21@lon2d=eos_file->Longitude_location
Temperature_A_21@lat2d=eos_file->Latitude_location
Temperature_A_21@unit="Temperature unit Kelvin"

Temperature_A_22=eos_file->Temperature_A_ascending(22,:,:)
Temperature_A_22@lon2d=eos_file->Longitude_location
Temperature_A_22@lat2d=eos_file->Latitude_location
Temperature_A_22@unit="Temperature unit Kelvin"

Temperature_A_23=eos_file->Temperature_A_ascending(23,:,:)
Temperature_A_23@lon2d=eos_file->Longitude_location
Temperature_A_23@lat2d=eos_file->Latitude_location
Temperature_A_23@unit="Temperature unit Kelvin"

xwks=gsn_open_wks("pdf","AIRS.2002.08.24.L3.RetStd_H008.v4.0.21.0.G06104133343_Temperature_A") ; open workstation


res=True ;plot mods desired
res@cnFillOn=True
res@gsnSpreadColors=True
res@cnLinesOn=False
res@cnFillMode = "RasterFill" ; faster

res@cnLevelSelectionMode = "ManualLevels" ; preset range defined
res@cnLevelSpacingF = 10
res@cnMinLevelValF = 180
res@cnMaxLevelValF = 330
res@lbLabelAutoStride = True
res@lbLabelFontAspectF = 2.5
gsn_define_colormap(xwks,"so4_23") ; choose colormap

res@tiMainString = "Temperature_Ascending at TempPrsLvls=0"
plot=gsn_csm_contour_map_ce(xwks,Temperature_A,res)

res@tiMainString = "Temperature_Ascending at TempPrsLvls=1"
plot=gsn_csm_contour_map_ce(xwks,Temperature_A_1,res)

res@tiMainString = "Temperature_Ascending at TempPrsLvls=2"
plot=gsn_csm_contour_map_ce(xwks,Temperature_A_2,res)

res@tiMainString = "Temperature_Ascending at TempPrsLvls=3"
plot=gsn_csm_contour_map_ce(xwks,Temperature_A_3,res)

res@tiMainString = "Temperature_Ascending at TempPrsLvls=4"
plot=gsn_csm_contour_map_ce(xwks,Temperature_A_4,res)

res@tiMainString = "Temperature_Ascending at TempPrsLvls=5"
plot=gsn_csm_contour_map_ce(xwks,Temperature_A_5,res)

res@tiMainString = "Temperature_Ascending at TempPrsLvls=6"
plot=gsn_csm_contour_map_ce(xwks,Temperature_A_6,res)

res@tiMainString = "Temperature_Ascending at TempPrsLvls=7"
plot=gsn_csm_contour_map_ce(xwks,Temperature_A_7,res)

res@tiMainString = "Temperature_Ascending at TempPrsLvls=8"
plot=gsn_csm_contour_map_ce(xwks,Temperature_A_8,res)

res@tiMainString = "Temperature_Ascending at TempPrsLvls=9"
plot=gsn_csm_contour_map_ce(xwks,Temperature_A_9,res)

res@tiMainString = "Temperature_Ascending at TempPrsLvls=10"
plot=gsn_csm_contour_map_ce(xwks,Temperature_A_10,res)

plot=gsn_csm_contour_map_ce(xwks,Temperature_A_11,res)
res@tiMainString = "Temperature_Ascending at TempPrsLvls=11"

res@tiMainString = "Temperature_Ascending at TempPrsLvls=12"
plot=gsn_csm_contour_map_ce(xwks,Temperature_A_12,res)

res@tiMainString = "Temperature_Ascending at TempPrsLvls=13"
plot=gsn_csm_contour_map_ce(xwks,Temperature_A_13,res)

res@tiMainString = "Temperature_Ascending at TempPrsLvls=14"
plot=gsn_csm_contour_map_ce(xwks,Temperature_A_14,res)

res@tiMainString = "Temperature_Ascending at TempPrsLvls=15"
plot=gsn_csm_contour_map_ce(xwks,Temperature_A_15,res)

res@tiMainString = "Temperature_Ascending at TempPrsLvls=16"
plot=gsn_csm_contour_map_ce(xwks,Temperature_A_16,res)

res@tiMainString = "Temperature_Ascending at TempPrsLvls=17"
plot=gsn_csm_contour_map_ce(xwks,Temperature_A_17,res)

res@tiMainString = "Temperature_Ascending at TempPrsLvls=18"
plot=gsn_csm_contour_map_ce(xwks,Temperature_A_18,res)

res@tiMainString = "Temperature_Ascending at TempPrsLvls=19"
plot=gsn_csm_contour_map_ce(xwks,Temperature_A_19,res)

res@tiMainString = "Temperature_Ascending at TempPrsLvls=20"
plot=gsn_csm_contour_map_ce(xwks,Temperature_A_20,res)

res@tiMainString = "Temperature_Ascending at TempPrsLvls=21"
plot=gsn_csm_contour_map_ce(xwks,Temperature_A_21,res)

res@tiMainString = "Temperature_Ascending at TempPrsLvls=22"
plot=gsn_csm_contour_map_ce(xwks,Temperature_A_22,res)

res@tiMainString = "Temperature_Ascending at TempPrsLvls=23"
plot=gsn_csm_contour_map_ce(xwks,Temperature_A_23,res)


delete(plot)
delete(Temperature_A)
delete(Temperature_A_1)
delete(Temperature_A_2)
delete(Temperature_A_3)
delete(Temperature_A_4)
delete(Temperature_A_5)
delete(Temperature_A_6)
delete(Temperature_A_7)
delete(Temperature_A_8)
delete(Temperature_A_9)
delete(Temperature_A_10)
delete(Temperature_A_11)
delete(Temperature_A_12)
delete(Temperature_A_13)
delete(Temperature_A_14)
delete(Temperature_A_15)
delete(Temperature_A_16)
delete(Temperature_A_17)
delete(Temperature_A_18)
delete(Temperature_A_19)
delete(Temperature_A_20)
delete(Temperature_A_21)
delete(Temperature_A_22)
delete(Temperature_A_23)
delete(res)
delete(eos_file)
end

