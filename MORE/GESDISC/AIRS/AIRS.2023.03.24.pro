; This example code illustrates how to access, merge, and visualize GESDISC
; AIRS Swath v7 files in IDL. 
;
; If you have any questions, suggestions, comments  on this example, 
; please use the HDF-EOS Forum (http://hdfeos.org/forums).
;
; If you would like to see an  example of any other NASA HDF/HDF-EOS 
; data product that is not listed in the HDF-EOS Comprehensive Examples page
; (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
; or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

; Usage:
;
; $idl
; IDL> .compile AIRS.2023.03.24.pro
; IDL> run
;
; Tested under: IDL 8.8.3
; Last updated: 2023-05-10


PRO run
  ; Search AIRS HDF files.
  hdf_search = FILE_SEARCH('AIRS.2023.03.24.*.hdf', count=hdf_count)
  IF hdf_count EQ 0 THEN RETURN
  PRINT, hdf_count
    
  ; Define Swath & dataset name.
  swath_name = 'L2_Support_atmospheric&surface_product'
  datafield_name = 'olr'

  FOR k = 0,hdf_count-1 DO BEGIN
    ; Open file.
    file_name = hdf_search[k]
    PRINT, hdf_search[k]

    file_id = EOS_SW_OPEN(file_name)
    swath_id = EOS_SW_ATTACH(file_id, swath_name)
    status = EOS_SW_READFIELD(swath_id, datafield_name, data1)
    status = EOS_SW_READFIELD(swath_id,'Longitude',lon1)
    status = EOS_SW_READFIELD(swath_id,'Latitude',lat1)
    IF ( k EQ 0 ) THEN BEGIN
       data = data1
       lon = lon1 
       lat = lat1
    ENDIF ELSE BEGIN 
       data = [data, data1]
       lon = [lon, lon1]
       lat = [lat, lat1]
    ENDELSE
    status=EOS_SW_DETACH(swath_id)
    status=EOS_SW_CLOSE(file_id)
  ENDFOR
  dataf=FLOAT(data)  

  ; Read fillvalue using HDFView.
  fillvaluef=-9999.0
  ; fillvaluef=FLOAT(fillvalue(0))

  ; Process fill values, convert data that are equal to fillvalue to NaN
  idx=WHERE(dataf EQ fillvaluef, cnt)
  IF cnt GT 0 THEN dataf[idx] = !Values.F_NAN


  ; Get max and min value of data for color bar.
  datamin = MIN(dataf, /NAN)
  datamax = MAX(dataf, /NAN)

  t = 'AIRS.2023.03.24'

  m = MAP('Geographic', TITLE=t, FONT_SIZE=9, /BUFFER)
  ct = COLORTABLE(72, /reverse)
  ; See [1].
  t1 = TEXT(0.35, 0.2, 'Outgoing Longwave Radiation')

  c1 = SCATTERPLOT(lon(*), lat(*), OVERPLOT=m, $
                   MAGNITUDE=dataf(*), $
                   RGB_TABLE=ct, $
                   POSITION=[0.1, 0.1, 0.83, 0.9],$
                   /SYM_FILLED, SYMBOL='o', SYM_SIZE=0.1)
  mc = MAPCONTINENTS()

  ; See [1]. The dataset doesn't have unit attribute.
  unit = 'W/m^2'
  cb = COLORBAR(RGB_TABLE=ct, RANGE=[datamin, datamax], $
                /BORDER, ORIENTATION=1, TEXTPOS=1, $
                POSITION=[0.85,0.2,0.87,0.8], TITLE=unit)
  png = t + '.pro.png'
  c1.save, png, HEIGHT=600, WIDTH=800
END
; Reference
;
; [1] https://airs.jpl.nasa.gov/data/products/v7-L2-L3/
