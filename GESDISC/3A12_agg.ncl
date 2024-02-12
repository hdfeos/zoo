;
;   This example code illustrates how to access and visualize GES DISC TRMM 
;  3A12 HDF4 Grid file in NCL. 
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
;
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
; post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Usage:save this script and run 
; 
; $ncl 3A12_agg.ncl
;
; Tested under: NCL 6.4.0
; Last updated: 2017-03-30

begin 
     ; Get list of all files and open as "one big file".
     all_files = systemfunc ("ls 3A12*.HDF")
     fall      = addfiles (all_files, "r")   ; note the "s" of addfile

     ; Choose how files are combined and read in variable across files.
     ListSetType (fall, "join")             ; See [1] for merge options.
     sp    = fall[:]->surfacePrecipitation
    
     ; The 2D surfacePreciptation array will appear as 3D array because we 
     ; join multiple files.
     printVarSummary(sp)
end

; References
; [1] https://www.ncl.ucar.edu/Document/Functions/Built-in/ListSetType.shtml
