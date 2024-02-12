; Copyright (C) 2019 The HDF Group
;   All Rights Reserved 
;
;  This example code illustrates how to access and visualize GPM L3
;  netCDF-4 files in IDL.
;
;  If you have any questions, suggestions, comments on this example, please 
; use the HDF-EOS Forum (http://hdfeos.org/forums). 
; 
;  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
; product that is not listed in the HDF-EOS Comprehensive Examples page 
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
;
; Usage:
;                               
; $idl
; IDL> .compile 3B-DAY-L.MS.MRG.3IMERG.20190330_20190406-avg-S000000-E235959.V06.nc4.pro
; IDL> run
; IDL> exit
;
; Tested under: IDL 8.6.0
; Last updated: 2019-10-07

PRO run
  nc4_search = FILE_SEARCH('.', '*.nc4', count=nc_count)
  IF nc_count EQ 0 THEN RETURN
  PRINT, nc_count
    
  ; Read lat/lon from the first file because the rest of files have same values.
  fileID = NCDF_OPEN(nc4_search[0])
  NCDF_VARGET, fileID, 'lon', lon
  NCDF_VARGET, fileID, 'lat', lat

  ; Read long_name and units attributes for plot.
  varID = NCDF_VARID(fileID,'precipitationCal')     
  NCDF_ATTGET, fileID, varID, 'long_name', long_name
  NCDF_ATTGET, fileID, varID, 'units', units

  FOR k=0,nc_count-1 DO BEGIN
    fileID = NCDF_OPEN(nc4_search[k])
    PRINT, nc4_search[k]
    NCDF_VARGET, fileID, 'precipitationCal', ppc
    IF ( k EQ 0 ) THEN $
       sum = ppc $
    ELSE $      
       sum = sum + ppc
  ENDFOR
  
  rainfall = sum/FLOAT(nc_count)
  file_name = '3B-DAY-L.MS.MRG.3IMERG.20190330_20190406-avg-S000000-E235959.V06.nc4'
  m = MAP('Geographic', TITLE=file_name, FONT_SIZE=9, /BUFFER)
  ct = COLORTABLE(72, /reverse)
  t1 = TEXT(0.05, 0.01, STRING(long_name)+' (average)')
  c1 = CONTOUR(rainfall, lon, lat, /FILL, OVERPLOT=m, $
               RGB_TABLE=ct, $
               GRID_UNITS='degrees', POSITION=[0.1, 0.1, 0.83, 0.9])
  mc = MAPCONTINENTS()
  cb = COLORBAR(TARGET=c1, /BORDER, ORIENTATION=1, TEXTPOS=1, $
                POSITION=[0.85,0.2,0.87,0.8], TITLE=STRING(units))
  png = file_name + '.pro.png'
  c1.save, png, HEIGHT=600, WIDTH=800

  ; Save the data in netCDF.
  ncdfid = NCDF_CREATE(file_name, /CLOBBER, /NETCDF4_FORMAT)

  dimsize=SIZE(lon,/dim)
  numlat=dimsize(0)
  xid = NCDF_DIMDEF(ncdfid, 'lon', numlat)

  dimsize=SIZE(lat,/dim)
  numlon=dimsize(0)
  yid = NCDF_DIMDEF(ncdfid, 'lat', numlon)


  varid = NCDF_VARDEF(ncdfid, 'precip_avg', [xid, yid], /FLOAT)
  NCDF_VARPUT, ncdfid, varid, rainfall
  NCDF_ATTPUT, ncdfid, varid, 'units', units
  NCDF_ATTPUT, ncdfid, varid, 'long_name', STRING(long_name)+' (avg)'

  latid = NCDF_VARDEF(ncdfid, 'lat', [yid], /FLOAT)
  NCDF_VARPUT, ncdfid, latid, lat
  NCDF_ATTPUT, ncdfid, latid, 'units', 'degrees_north'

  lonid = NCDF_VARDEF(ncdfid, 'lon', [xid], /FLOAT)
  NCDF_VARPUT, ncdfid, lonid, lon
  NCDF_ATTPUT, ncdfid, lonid, 'units', 'degrees_east'

  NCDF_CLOSE, ncdfid
END
